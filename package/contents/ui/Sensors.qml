/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick

import org.kde.plasma.plasmoid

import org.kde.ksysguard.sensors as Sensors
import org.kde.quickcharts as Charts

import "../code/formatter.js" as Formatter

Item {
    id: sensorContainer

    readonly property list<var> rawSensors: JSON.parse(Plasmoid.configuration.sensors) ?? []
    property list<QtObject> sensors: []

    readonly property var globalMin: {
        let minValues = sensors.map(item => item.min).filter(val => val !== undefined);
        return minValues.length > 0 ? Math.min(...minValues) : undefined;
    }
    readonly property var globalMax: {
        let maxValues = sensors.map(item => item.max).filter(val => val !== undefined);
        return maxValues.length > 0 ? Math.max(...maxValues) : undefined;
    }

    onRawSensorsChanged: {
        // Empty list and destroy items
        while (sensors.length > 0) {
            sensors.pop().destroy();
        }

        // Create new items
        rawSensors.forEach(item => sensors.push(sensorComponent.createObject(sensorContainer, {
            name: item.name,
            sensorId: item.sensorId
        })));
    }

    Component {
        id: sensorComponent

        Item {
            id: sensorItem

            property string name
            property alias sensorId: sensor.sensorId

            readonly property int unit: Plasmoid.configuration.temperatureUnit

            readonly property var value: sensor.isValueReady
                                          ? Formatter.convertUnit(sensor.value, Formatter.Units.Celsius, unit)
                                          : undefined

            readonly property var history: historySource

            readonly property var maxCount: historyModel.maximumLength

            readonly property var avg: historyModel.average;

            readonly property var min: historyModel.minimum;

            readonly property var max: historyModel.maximum;

            readonly property var globalMin: sensorContainer.globalMin

            readonly property var globalMax: sensorContainer.globalMax

            function clearHistory() : void {
                historyModel.reset();
            }

            Sensors.Sensor {
                id: sensor

                property bool isValueReady: false

                onValueChanged: {
                    if (!isValueReady && value !== 0 && value !== undefined) {
                        isValueReady = true;
                    }
                }

                updateRateLimit: Plasmoid.configuration.updateInterval * 1000
            }

            Connections {
                target: Plasmoid.configuration

                function onTemperatureUnitChanged() : void {
                    // We used to convert the values, but for some reason it
                    // started to cause a crash — even when refactored to store
                    // the raw values. Best to just clear them.
                    historyModel.reset()
                }

                function onUpdateIntervalChanged() : void {
                    // We can't really do anything useful with the original
                    // history to retain data, so just clear it.
                    historyModel.reset()
                }

                function onStatsHistoryChanged() : void {
                    // We can prepend existing data with undefined, capped at
                    // the new length, but it's easier to just clear it.
                    historyModel.reset()
                }
            }

            // To have our own metrics, we can't use the data accumulated in
            // historyProxySource, so we must track it ourselves.
            ListModel {
                id: historyModel

                readonly property int maximumLength: Plasmoid.configuration.statsHistory / Plasmoid.configuration.updateInterval

                // Used to derive average
                property int valuesCount: 0
                property var valuesSum: 0

                property var average: undefined

                // Track whether our min/max was removed
                property int minIndex: -1
                property int maxIndex: -1

                // ModelSource uses these properties
                property var minimum: undefined
                property var maximum: undefined

                // Used to insert gaps where they should exist
                property var lastTickTime: undefined

                function tick(newValue: var): void {
                    if (typeof newValue !== "number" || isNaN(newValue)) {
                        return;
                    }

                    // Handle gaps in time
                    let tickTime = Date.now();
                    if (lastTickTime) {
                        let gap = tickTime - lastTickTime;
                        while (gap > 1500) {
                            // Would rather use null. Can't.
                            insert(0, { "value": -2147483648 });
                            ++minIndex;
                            ++maxIndex;
                            gap -= 1000;
                        }
                    }
                    lastTickTime = tickTime;

                    // Add new value
                    insert(0, { "value": newValue });

                    // Update properties
                    ++valuesCount;
                    valuesSum += newValue;
                    ++minIndex;
                    ++maxIndex;

                    // Cap model count and handle removed value
                    while (count > maximumLength) {
                        const removed = historyModel.get(maximumLength).value;
                        historyModel.remove(maximumLength);
                        if (removed !== -2147483648) {
                            // See usage above
                            valuesSum -= removed;
                            --valuesCount;
                        }
                    }

                    average = valuesSum / valuesCount;

                    // Check if min/max out of range, or if new value is a better min/max
                    if (minIndex >= maximumLength) {
                        let r = findBest((a, b) => a < b);
                        minIndex = r.index;
                        minimum = r.value;
                    } else if (minimum === undefined || newValue <= minimum) {
                        minIndex = 0;
                        minimum = newValue;
                    }

                    if (maxIndex >= maximumLength) {
                        let r = findBest((a, b) => a > b);
                        maxIndex = r.index;
                        maximum = r.value;
                    } else if (maximum === undefined || newValue >= maximum) {
                        maxIndex = 0;
                        maximum = newValue;
                    }
                }

                function findBest(compare) {
                    let bestIndex = -1;
                    let bestValue = undefined;

                    for (let i = 0; i < historyModel.count; ++i) {
                        let v = historyModel.get(i).value;

                        if (v == -2147483648) {
                            // See usage above
                            continue;
                        }

                        if (bestValue === undefined || compare(v, bestValue)) {
                            bestIndex = i;
                            bestValue = v;
                        }
                    }

                    return bestValue === undefined ? { index: -1,        value: undefined }
                                                   : { index: bestIndex, value: bestValue };
                }

                function reset(): void {
                    valuesCount = 0;
                    valuesSum = 0;
                    average = undefined;
                    minIndex = -1;
                    maxIndex = -1;
                    minimum = undefined;
                    maximum = undefined;
                    lastTickTime = undefined;

                    clear();
                    tick(sensorItem.value);
                }

                Component.onCompleted: reset()
            }

            // We also must poll the value ourselves because Sensor does not
            // reliably fire valueChanged every updateInterval ms — it is
            // sometimes updateInterval + 500 ms.
            Timer {
                id: historyTimer

                interval: Plasmoid.configuration.updateInterval * 1000
                repeat: true
                running: sensor.isValueReady
                triggeredOnStart: true

                onTriggered: historyModel.tick(sensorItem.value)
            }

            Charts.ModelSource {
                id: historySource
                model: historyModel
                roleName: "value"

                readonly property bool ready: historyModel.count > 0
            }
        }
    }
}
