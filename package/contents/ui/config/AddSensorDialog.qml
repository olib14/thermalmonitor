/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.Dialog {
    id: dialog

    property list<string> addedSensorIds: []

    signal addedSensor(name: string, sensorId: string)
    signal removedSensor(sensorId: string)

    title: "Add Sensor"

    showCloseButton: true
    standardButtons: Kirigami.Dialog.NoButton

    ListView {
        id: view

        AvailableSensors {
            id: availableSensorsItem
        }

        model: availableSensorsItem.model

        implicitWidth: Kirigami.Units.gridUnit * 24
        implicitHeight: Kirigami.Units.gridUnit * 16

        section {
            property: "section"
            delegate: Kirigami.ListSectionHeader {
                required property string section
                width: view.width
                text: section
            }
        }

        delegate: QQC2.ItemDelegate {

            required property int index
            required property string name
            required property string sensorId

            readonly property bool added: dialog.addedSensorIds.includes(sensorId)

            width: view.width

            down: false
            highlighted: false
            hoverEnabled: false
            Kirigami.Theme.useAlternateBackgroundColor: true

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Label {
                    Layout.fillWidth: true

                    text: name
                    elide: Text.ElideRight

                    opacity: added ? 0.6 : 1

                    QQC2.ToolTip.visible: nameHoverHandler.hovered
                    QQC2.ToolTip.delay: Application.styleHints.mousePressAndHoldInterval
                    QQC2.ToolTip.text: (truncated ? name + "\n" : "" ) + sensorId
                    HoverHandler { id: nameHoverHandler }
                }

                QQC2.ToolButton {
                    icon.name: added ? "edit-undo-symbolic" : "list-add-symbolic"
                    onClicked: added ? dialog.removedSensor(sensorId) : dialog.addedSensor(name, sensorId)

                    QQC2.ToolTip {
                        text: added ? "Undo" : "Add"
                    }
                }
            }
        }
    }
}
