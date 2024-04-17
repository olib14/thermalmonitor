/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root

    readonly property var sensors: JSON.parse(Plasmoid.configuration.sensors)
    readonly property bool hasSensors: sensors.length

    readonly property double fontScale: Plasmoid.configuration.fontScale

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    preferredRepresentation: hasSensors ? fullRepresentation : compactRepresentation
    fullRepresentation: GridLayout {

        readonly property bool isVertical: {
            switch (Plasmoid.formFactor) {
                case PlasmaCore.Types.Planar:
                case PlasmaCore.Types.MediaCenter:
                case PlasmaCore.Types.Application:
                default:
                    if (root.height > root.width) {
                        return true;
                    } else {
                        return false;
                    }
                case PlasmaCore.Types.Vertical:
                    return true;
                case PlasmaCore.Types.Horizontal:
                    return false;
            }
        }

        width:  isVertical ? root.width : implicitWidth
        height: isVertical ? implicitHeight : root.height

        flow:   isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

        columnSpacing: Kirigami.Units.smallSpacing * fontScale
        rowSpacing:    Kirigami.Units.smallSpacing * fontScale

        Repeater {
            model: root.sensors
            delegate: TemperatureDelegate { name: modelData.name; sensorId: modelData.sensorId }
        }

        PlasmaComponents.Button {
            visible: !root.hasSensors
            text: "Configure…"
            onClicked: Plasmoid.internalAction("configure").trigger()
        }
    }
}
