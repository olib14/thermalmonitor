/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick 2.15

import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.ksysguard.sensors 1.0 as Sensors

import org.kde.kirigami 2.20 as Kirigami

// Used in a Loader to make UI load when
// org.kde.ksysguard.sensors is not available

// e.g. loader.status !== Loader.Ready

Item {
    property var treeModel: Sensors.SensorTreeModel {}
    property var flatModel: KItemModels.KDescendantsProxyModel {
        model: treeModel
    }
    property var sensorsModel: KItemModels.KSortFilterProxyModel {
        sourceModel: flatModel
        filterRowCallback: (row, parent) => {
            // Checking sensorId length filters out non-sensors
            // TODO: Filter out group and non-temperature sensors (via unit) more sensibly
            let sensorId = sourceModel.data(sourceModel.index(row, 0), Sensors.SensorTreeModel.SensorId);
            let display = sourceModel.data(sourceModel.index(row, 0), Qt.DisplayRole);
            return sensorId.length > 0 && sensorId.toLowerCase().includes("temp") && !display.includes("[Group]");
        }

        onRowsInserted: (parent, first, last) => {
            //console.log("rowsInserted", first, last);
            for (var i = first; i <= last; ++i) {
                // Ignore when outside range
                // Rows are initially inserted strangely, so this suppresses errors
                // and everything comes out working anyway
                if (i > availableSensorsModel.count)
                    return;

                let index = sensorsModel.index(i, 0);
                let name = sensorsModel.data(index, Qt.DisplayRole).replace(" (°C)", "");
                let sensorId = sensorsModel.data(index, Sensors.SensorTreeModel.SensorId);

                let categoryIndex = flatModel.mapToSource(sensorsModel.mapToSource(index));
                while (categoryIndex.parent.valid) {
                    categoryIndex = categoryIndex.parent;
                }

                let section = treeModel.data(categoryIndex, Qt.DisplayRole);

                //console.log("adding sensor:", name, "(" + section + ", " + sensorId + ")");
                availableSensorsModel.set(i, { "name": name, "sensorId": sensorId, "section": section });
            }
        }

        onRowsRemoved: (parent, first, last) => {
            //console.log("rowsRemoved", first, last);
            for (var i = last; i >= first; --i) {
                //console.log("removing sensor", i);
                availableSensorsModel.remove(i);
            }
        }
    }
    property var availableSensorsModel: ListModel {}
}
