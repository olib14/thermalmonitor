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

            property int unit: Plasmoid.configuration.temperatureUnit

            readonly property var value: sensor.isValueReady
                                          ? Formatter.convertUnit(sensor.value, Formatter.Units.Celsius, unit)
                                          : undefined

            readonly property var history: historySource

            readonly property var avg: history.filteredValues.length === 0
                                        ? undefined
                                        : history.filteredValues.reduce((acc, v) => acc + v, 0) / history.filteredValues.length;

            readonly property var min: history.filteredValues.length === 0
                                        ? undefined
                                        : Math.min(...history.filteredValues)

            readonly property var max: history.filteredValues.length === 0
                                        ? undefined
                                        : Math.max(...history.filteredValues)

            readonly property var globalMin: sensorContainer.globalMin

            readonly property var globalMax: sensorContainer.globalMax

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
                    history.clear();
                }

                function onUpdateIntervalChanged() : void {
                    // We can't really do anything useful with the original
                    // history to retain data, so just clear it.
                    history.clear();
                }

                function onStatsHistoryChanged() : void {
                    // We can prepend existing data with undefined, capped at
                    // the new length, but it's easier to just clear it.
                    history.clear();
                }
            }

            // To have our own metrics, we can't use the data accumulated in
            // historyProxySource, so we must track it ourselves.
            // We also must poll the value ourselves because Sensor does not
            // reliably fire valueChanged every updateInterval ms — it is
            // sometimes updateInterval + 500 ms.
            Timer {
                id: history

                property int maximumLength: (Plasmoid.configuration.statsHistory * 1000) / interval
                property list<var> values: Array(maximumLength).fill(undefined)
                property list<var> filteredValues: values.filter(value => value !== undefined && value !== NaN)

                interval: Plasmoid.configuration.updateInterval * 1000
                repeat: true
                running: sensor.isValueReady
                triggeredOnStart: true

                onTriggered: values = [sensorItem.value, ...values.slice(0, maximumLength - 1)]

                function clear() {
                    values.fill(undefined);
                    triggered();
                }
            }

            Charts.ArraySource {
                id: historySource
                array: history.values

                readonly property bool ready: history.filteredValues.length > 0
            }
        }
    }
}
