/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.ksvg as KSvg

MouseArea {
    id: compactRepresentation

    property bool wasExpanded: false
    property int pressedSensor: -1

    readonly property double fontScale: Plasmoid.configuration.fontScale

    readonly property bool isVertical: {
        switch (Plasmoid.formFactor) {
            case PlasmaCore.Types.Vertical:
                return true;
            case PlasmaCore.Types.Horizontal:
                return false;
            case PlasmaCore.Types.Planar:
            case PlasmaCore.Types.MediaCenter:
            case PlasmaCore.Types.Application:
            default:
                return height > width;
        }
    }

    readonly property bool isPanel: {
        switch (Plasmoid.location) {
            case PlasmaCore.Types.Floating:
            case PlasmaCore.Types.Desktop:
            case PlasmaCore.Types.FullScreen:
            default:
                return false;
            case PlasmaCore.Types.TopEdge:
            case PlasmaCore.Types.BottomEdge:
            case PlasmaCore.Types.LeftEdge:
            case PlasmaCore.Types.RightEdge:
                return true;
        }
    }

    Layout.preferredWidth:  isVertical ? -1 : layout.implicitWidth
    Layout.preferredHeight: isVertical ? layout.implicitHeight : -1
    Layout.minimumWidth:    isPanel ? Layout.preferredWidth : layout.implicitWidth
    Layout.minimumHeight:   isPanel ? Layout.preferredHeight : layout.implicitHeight

    hoverEnabled: true
    onPositionChanged: (mouse) => handlePositionChanged(mouse)
    onPressed:         (mouse) => handlePressed(mouse)
    onClicked:         (mouse) => handleClicked(mouse)
    onWheel:           (wheel) => handleWheel(wheel)

    // COMPAT: Qt 6.8.2, MouseEvent is not a type
    function handlePositionChanged(mouse) : void {
        root.hoveredSensor = findClosestSensor(mouse.x, mouse.y);
    }

    // COMPAT: Qt 6.8.2, MouseEvent is not a type
    function handlePressed(mouse) : void {
        wasExpanded = root.expanded;

        if (root.needsConfiguration || !isPanel) {
            return;
        }

        pressedSensor = findClosestSensor(mouse.x, mouse.y);
    }

    // COMPAT: Qt 6.8.2, MouseEvent is not a type
    function handleClicked(mouse) : void {
        // TODO: Improve desktop behaviour - switch representation, find way to
        // disable highlight on desktop, many opportunities.
        // For now, no popup on desktop.
        if (!isPanel) {
            if (root.needsConfiguration) {
                Plasmoid.internalAction("configure").trigger();
            }

            return;
        }

        if (root.needsConfiguration) {
            root.expanded = !wasExpanded;
        }

        let clickedSensor = findClosestSensor(mouse.x, mouse.y);

        if (clickedSensor != pressedSensor) {
            return;
        }

        if (!root.expanded) {
            // If closed, open with requested index
            root.activeSensor = clickedSensor;
            root.expanded = !wasExpanded;
        } else if (root.activeSensor == clickedSensor) {
            // If open, and same index, close
            root.expanded = !wasExpanded;
        } else {
            // If open, and different index, set requested index
            root.activeSensor = clickedSensor;
        }
    }

    // COMPAT: Qt 6.8.2, WheelEvent is not a type
    function handleWheel(wheel) : void {
        if (root.needsConfiguation || root.sensors.length < 2 || !Plasmoid.configuration.scrollApplet) {
            return;
        }

        //let delta = wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x;
        // TODO: Test inverted with touchpad, left/right too
        let delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x);

        // Scroll up/right -> decrease index
        while (delta >= 120) {
            delta -= 120;

            if (root.activeSensor === -1) {
                // No active sensor
                root.activeSensor = root.sensors.length - 1;
            } else {
                // Active sensor
                root.activeSensor = Plasmoid.configuration.scrollWraparound ? (root.activeSensor - 1 + root.sensors.length) % root.sensors.length
                                                                            : Math.max(root.activeSensor - 1, 0);
            }
        }

        // Scroll down/left -> increase index
        while (delta <= -120) {
            delta += 120;

            if (root.activeSensor === -1) {
                // No active sensor
                root.activeSensor = 0;
            } else {
                // Active sensor
                root.activeSensor = Plasmoid.configuration.scrollWraparound ? (root.activeSensor + 1) % root.sensors.length
                                                                            : Math.min(root.activeSensor + 1, root.sensors.length - 1);
            }
        }

        if (Plasmoid.configuration.scrollAppletOpensPopup) {
            root.expanded = true;
        }
    }

    function findClosestSensor(x: real, y: real) : int {
        // Required because a mouse area on each delegate would have gaps on all
        // sides - getting the closest is the best way to ensure input is
        // registered as expected

        let minDistance = Number.MAX_VALUE;
        let closestSensor = 0;

        for (let i = 0; i < layout.visibleChildren.length; ++i) {
            let item = layout.visibleChildren[i];

            // Get the closest X and Y on the item's edges - center doesn't work
            let closestX = Math.max(item.x, Math.min(x, item.x + item.width));
            let closestY = Math.max(item.y, Math.min(y, item.y + item.height));

            let distance = Math.sqrt(Math.pow(closestX - x, 2) + Math.pow(closestY - y, 2));

            if (distance < minDistance) {
                minDistance = distance;
                closestSensor = i;
            }
        }

        return closestSensor;
    }

    GridLayout {
        id: layout
        anchors.fill: parent

        flow: isVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight

        columnSpacing: Kirigami.Units.smallSpacing * fontScale
        rowSpacing:    Kirigami.Units.smallSpacing * fontScale

        Kirigami.Icon {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            source: plasmoid.icon
            active: compactRepresentation.containsMouse
            activeFocusOnTab: true
            visible: root.needsConfiguration
        }

        Repeater {
            id: sensorRepeater

            model: root.sensors
            delegate: CompactDelegate {
                Layout.leftMargin:   isVertical ? 0 : Kirigami.Units.smallSpacing * fontScale
                Layout.rightMargin:  isVertical ? 0 : Kirigami.Units.smallSpacing * fontScale
                Layout.topMargin:    isVertical ? Kirigami.Units.smallSpacing * fontScale : 0
                Layout.bottomMargin: isVertical ? Kirigami.Units.smallSpacing * fontScale : 0
                Layout.alignment:    Qt.AlignHCenter | Qt.AlignVCenter

                sensorName: name
                sensorUnit: unit
                sensorValue: value
            }
        }
    }
}
