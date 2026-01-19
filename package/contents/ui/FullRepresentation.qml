/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.extras as PlasmaExtras
import org.kde.kirigami as Kirigami

PlasmaExtras.Representation {
    id: fullRepresentation
    Layout.preferredWidth: Layout.minimumWidth
    Layout.preferredHeight: Layout.minimumHeight
    Layout.minimumWidth: Kirigami.Units.gridUnit * 16
    Layout.minimumHeight: Kirigami.Units.gridUnit * 10
    Layout.maximumWidth: Kirigami.Units.gridUnit * 32
    Layout.maximumHeight: Kirigami.Units.gridUnit * 20

    readonly property alias pinned: pinButton.checked

    header: PlasmaExtras.PlasmoidHeading {

        contentHeight: headerLayout.implicitHeight
        position: PlasmaComponents.ToolBar.Header

        RowLayout {
            id: headerLayout
            anchors.fill: parent

            PlasmaComponents.ToolButton {
                id: leftButton
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                icon.name: "go-previous-symbolic"
                text: "Previous Sensor"
                display: PlasmaComponents.ToolButton.IconOnly
                enabled: root.activeSensor > 0
                visible: root.sensors.length > 1

                PlasmaComponents.ToolTip.text: text
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                PlasmaComponents.ToolTip.visible: hovered

                onClicked: root.activeSensor = Math.max(0, root.activeSensor - 1)

                Shortcut {
                    sequence: "Left"
                    onActivated: leftButton.clicked()
                    enabled: root.activeSensor !== -1
                }
            }

            PlasmaComponents.ToolButton {
                id: rightButton
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter

                icon.name: "go-next-symbolic"
                text: "Next Sensor"
                display: PlasmaComponents.ToolButton.IconOnly
                enabled: root.activeSensor < (root.sensors.length - 1)
                visible: root.sensors.length > 1

                PlasmaComponents.ToolTip.text: text
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                PlasmaComponents.ToolTip.visible: hovered

                onClicked: root.activeSensor = Math.min(root.sensors.length - 1, root.activeSensor + 1)

                Shortcut {
                    sequence: "Right"
                    onActivated: rightButton.clicked()
                    enabled: root.activeSensor !== -1
                }
            }

            PlasmaExtras.Heading {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true

                text: root.sensors[root.activeSensor]?.name ?? Plasmoid.title
                maximumLineCount: 1
                elide: Text.ElideRight
            }

            PlasmaComponents.ToolButton {
                id: clearButton
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                icon.name: "edit-clear-history-symbolic"
                text: "Clear History"
                display: PlasmaComponents.ToolButton.IconOnly

                PlasmaComponents.ToolTip.text: text
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                PlasmaComponents.ToolTip.visible: hovered

                onClicked: root.sensors[root.activeSensor]?.clearHistory() ?? undefined
            }

            PlasmaComponents.ToolButton {
                id: configureButton
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                icon.name: "configure-symbolic"
                text: Plasmoid.internalAction("configure").text
                display: PlasmaComponents.ToolButton.IconOnly

                PlasmaComponents.ToolTip.text: text
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                PlasmaComponents.ToolTip.visible: hovered

                onClicked: Plasmoid.internalAction("configure").trigger()
            }

            PlasmaComponents.ToolButton {
                id: pinButton
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter

                icon.name: "window-pin-symbolic"
                text: "Keep Open"
                display: PlasmaComponents.ToolButton.IconOnly

                PlasmaComponents.ToolTip.text: text
                PlasmaComponents.ToolTip.delay: Kirigami.Units.toolTipDelay
                PlasmaComponents.ToolTip.visible: hovered

                checkable: true
                checked: Plasmoid.configuration.pinned
                onToggled: Plasmoid.configuration.pinned = checked
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent

        visible: root.needsConfiguration

        spacing: Kirigami.Units.gridUnit

        PlasmaExtras.Heading {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            text: "Add a sensor to get started"
            level: 2
        }

        PlasmaComponents.Button {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            icon.name: Plasmoid.internalAction("configure").icon.name
            text: Plasmoid.internalAction("configure").text
            onClicked: Plasmoid.internalAction("configure").trigger()
        }
    }

    ListView {
        id: listView
        anchors.fill: parent
        // Account for margins in Representation - actually fill the view
        anchors.margins: -Kirigami.Units.smallSpacing
        anchors.topMargin: 0

        visible: !root.needsConfiguration

        currentIndex: root.activeSensor
        onCurrentIndexChanged: root.activeSensor = currentIndex

        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem

        highlightRangeMode: ListView.StrictlyEnforceRange

        preferredHighlightBegin: 0
        preferredHighlightEnd: width

        highlightMoveDuration: Kirigami.Units.longDuration
        highlightResizeDuration: Kirigami.Units.longDuration

        spacing: 0

        model: root.sensors
        delegate: Item {
            width: listView.width
            height: listView.height

            FullDelegate {
                anchors.fill: parent
                anchors.margins: Kirigami.Units.smallSpacing * 2

                sensorName: name
                sensorUnit: unit
                sensorValue: value
                sensorHistory: history
                sensorAvg: avg
                sensorMin: min
                sensorMax: max
                sensorGlobalMin: globalMin
                sensorGlobalMax: globalMax
            }
        }

        // TODO: Better to use WheelHandler?
        /*
        WheelHandler {
            id: wheelHandler

            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

            onWheel: (event) => {
                const steps = Math.trunc(wheelHandler.rotation / 15); // 15 degrees is 120 angleDelta is 1 steps
                if (steps !== 0) {
                    wheelHandler.rotation -= steps * 15;
                    // TODO: Handle based on steps
                }
            }
        }
        */

        MouseArea {
            anchors.fill: parent

            onWheel: (wheel) => {
                if (root.needsConfiguation || root.sensors.length < 2 || !Plasmoid.configuration.scrollPopup) {
                    return;
                }

                //let delta = wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x;
                // TODO: Test inverted with touchpad, left/right too
                let delta = (wheel.inverted ? -1 : 1) * (wheel.angleDelta.y ? wheel.angleDelta.y : wheel.angleDelta.x);

                // Scroll up/right -> decrease index
                while (delta >= 120) {
                    delta -= 120;
                    root.activeSensor = Plasmoid.configuration.scrollWraparound ? (root.activeSensor - 1 + root.sensors.length) % root.sensors.length
                                                                                : Math.max(root.activeSensor - 1, 0);
                }

                // Scroll down/left -> increase index
                while (delta <= -120) {
                    delta += 120;
                    root.activeSensor = Plasmoid.configuration.scrollWraparound ? (root.activeSensor + 1) % root.sensors.length
                                                                                : Math.min(root.activeSensor + 1, root.sensors.length - 1);
                }
            }
        }
    }
}
