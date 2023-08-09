/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    //toolTipMainText: Plasmoid.title
    //toolTipSubText: Plasmoid.description

    //readonly property var sensors: JSON.parse("[{\"name\":\"CPU\",\"sensorId\":\"cpu\/all\/averageTemperature\"},{\"name\":\"GPU\",\"sensorId\":\"gpu\/gpu0\/temperature\"},{\"name\":\"HDD\",\"sensorId\":\"\"}]")

    readonly property var sensors: JSON.parse(Plasmoid.configuration.sensors)
    /*
    readonly property var sensors: ListModel {
        ListElement { name: "CPU"; sensorId: "cpu/all/averageTemperature" }
        ListElement { name: "GPU"; sensorId: "gpu/gpu0/temperature" }
        ListElement { name: "HDD"; sensorId: "" }
    }
    */

    Plasmoid.configurationRequired: !sensors.length

    preferredRepresentation: fullRepresentation
    fullRepresentation: GridLayout {

        readonly property bool isPanel: {
            switch (Plasmoid.formFactor) {
                case PlasmaCore.Types.Planar:
                case PlasmaCore.Types.MediaCanter:
                case PlasmaCore.Types.Application:
                    return false
                case PlasmaCore.Types.Vertical:
                case PlasmaCore.Types.Horizontal:
                    return true
                default:
                    return false
            }
        }

        readonly property bool isVertical: {
            switch (Plasmoid.formFactor) {
                case PlasmaCore.Types.Planar:
                case PlasmaCore.Types.MediaCanter:
                case PlasmaCore.Types.Application:
                    if (root.height > root.width) {
                        return true
                    } else {
                        return false
                    }
                case PlasmaCore.Types.Vertical:
                    return true
                case PlasmaCore.Types.Horizontal:
                default:
                    return false
            }
        }

        flow:   isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        width:  isVertical ? root.width : implicitWidth
        height: isVertical ? implicitHeight : root.height

        columnSpacing: Kirigami.Units.largeSpacing
        rowSpacing:    Kirigami.Units.largeSpacing

        /*
        TemperatureDelegate { name: "CPU"; sensorId: "cpu/all/averageTemperature" }
        TemperatureDelegate { name: "GPU"; sensorId: "gpu/gpu0/temperature" }
        TemperatureDelegate { name: "HDD"; sensorId: "" }
        */

        Repeater {
            id: delegateRepeater

            model: root.sensors
            delegate: TemperatureDelegate { name: modelData.name; sensorId: modelData.sensorId }
        }

        Kirigami.Icon {
            visible: Plasmoid.configurationRequired

            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Layout.minimumWidth: {
                switch (Plasmoid.formFactor) {
                case PlasmaCore.Types.Vertical:
                    return 0;
                case PlasmaCore.Types.Horizontal:
                    return height;
                default:
                    return Kirigami.Units.gridUnit * 3;
                }
            }

            Layout.minimumHeight: {
                switch (Plasmoid.formFactor) {
                case PlasmaCore.Types.Vertical:
                    return width;
                case PlasmaCore.Types.Horizontal:
                    return 0;
                default:
                    return Kirigami.Units.gridUnit * 3;
                }
            }

            source: Plasmoid.icon

            active: mouseArea.containsMouse
            activeFocusOnTab: true

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                onClicked: Plasmoid.configure()
            }
        }
    }
}
