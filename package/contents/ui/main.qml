/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami

Item {
    id: root

    readonly property var sensors: JSON.parse(Plasmoid.configuration.sensors)

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground
    Plasmoid.configurationRequired: !sensors.length

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.fullRepresentation: GridLayout {
        id: fullRepresentation

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
                    if (fullRepresentation.height > fullRepresentation.width) {
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
        width:  isVertical ? fullRepresentation.width : implicitWidth
        height: isVertical ? implicitHeight : fullRepresentation.height

        columnSpacing: Kirigami.Units.largeSpacing
        rowSpacing:    Kirigami.Units.largeSpacing

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

            MouseArea {
                id: mouseArea

                anchors.fill: parent
                onClicked: Plasmoid.configure()
            }
        }
    }
}
