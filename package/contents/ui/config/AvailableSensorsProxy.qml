/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick

import org.kde.kitemmodels 1.0 as KItemModels
import org.kde.ksysguard.sensors as Sensors

import org.kde.kirigami as Kirigami

// Used in a Loader to make UI load when
// org.kde.ksysguard.sensors is not available

// e.g. loader.status !== Loader.Ready

Item {
    id: availableSensors

    readonly property var sensorRole: Sensors.SensorTreeModel.SensorId
    property alias model: model

    Sensors.SensorTreeModel {
        id: sensorTreeModel
    }

    KItemModels.KDescendantsProxyModel {
        id: descendantsModel

        model: sensorTreeModel
    }

    KItemModels.KSortFilterProxyModel {
        id: filterModel

        sourceModel: descendantsModel
        filterRowCallback: (row, parent) => {
            let display = sourceModel.data(sourceModel.index(row, 0), Qt.DisplayRole);
            let sensorId = sourceModel.data(sourceModel.index(row, 0), sensorRole);

            // Filter: remove non-sensors, only temperature and remove groups
            return sensorId.length > 0 && display.includes("(°C)") && !display.includes("[");
        }

        onRowCountChanged: model.update();
    }

    // Custom model, so we can give sensors better names and categorise them
    ListModel {
        id: model

        function update() {
            clear();
            for (let i = 0; i < filterModel.rowCount(); ++i) {
                let index = filterModel.index(i, 0);

                // Get name without unit, and sensorId
                let name = filterModel.data(index, Qt.DisplayRole).replace(" (°C)", "");
                let sensorId = filterModel.data(index, sensorRole);

                // Get category and subcategory indexes
                let categoryIndex = descendantsModel.mapToSource(filterModel.mapToSource(index));
                let subcategoryIndex = null;
                while (categoryIndex.parent.valid) {
                    subcategoryIndex = categoryIndex;
                    categoryIndex = categoryIndex.parent;
                }

                // Get category and subcategory names
                let categoryName = sensorTreeModel.data(categoryIndex, Qt.DisplayRole);
                let subcategoryName = sensorTreeModel.data(subcategoryIndex, Qt.DisplayRole);

                // For Hardware Sensors, prepend the subcategory name
                if (sensorId.includes("lmsensors")) {
                    name = subcategoryName + ": " + name;
                }

                //console.log("adding sensor:", name, "(" + categoryName + ", " + sensorId + ")");
                model.set(i, { "name": name, "sensorId": sensorId, "section": categoryName });
            }
        }
    }
}
