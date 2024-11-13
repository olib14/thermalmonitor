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

            property int unit: -1

            readonly property var value: sensor.isValueReady
                                          ? Formatter.convertUnit(sensor.value, Formatter.Units.Celsius, Plasmoid.configuration.temperatureUnit)
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

            Component.onCompleted: sensorItem.unit = Plasmoid.configuration.temperatureUnit
            Connections {
                target: Plasmoid.configuration

                function onTemperatureUnitChanged() : void {
                    history.values = history.values.map(value => Formatter.convertUnit(value, sensorItem.unit, Plasmoid.configuration.temperatureUnit));
                    sensorItem.unit = Plasmoid.configuration.temperatureUnit;
                }
            }

            // To have our own metrics, we can't use the data accumulated in
            // historyProxySource, so we must track it ourselves
            Timer {
                id: history

                property int maximumLength: (Plasmoid.configuration.statsHistory * 1000) / interval
                property list<var> values: Array(maximumLength).fill(undefined)
                property list<int> filteredValues: values.filter(value => value !== undefined)

                interval: Plasmoid.configuration.updateInterval * 1000
                repeat: true
                running: sensor.isValueReady
                triggeredOnStart: true

                onTriggered: values = [sensorItem.value, ...values.slice(0, maximumLength - 1)]

                onIntervalChanged: {
                    values = Array(maximumLength).fill(undefined);
                }

                onMaximumLengthChanged: {
                    let fillCount = Math.max(0, maximumLength - values.length);
                    values = [...values.slice(0, maximumLength), ...Array(fillCount).fill(undefined)];
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
