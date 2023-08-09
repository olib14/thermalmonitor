/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQml.Models

import org.kde.kirigami as Kirigami
import org.kde.kirigamiaddons.components as KirigamiComponents

ColumnLayout {
    id: root

    property string cfg_sensors
    readonly property bool libAvailable: availableSensorsLoader.status === Loader.Ready

    spacing: 0

    ColumnLayout {
        spacing: 0

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        KirigamiComponents.Banner {
            id: libBanner

            Layout.fillWidth: true

            visible: !root.libAvailable

            title: "Required libraries missing"
            text: "The libraries <i>ksystemstats</i> (and <i>libksysguard</i>), <i>kitemmodels</i> are used to retrieve sensor data and are required to use this applet. Please ensure they are installed."
            type: Kirigami.MessageType.Error
        }
    }

    ListView {
        id: sensorsView

        Layout.fillWidth: true
        Layout.fillHeight: true

        Rectangle {
            // Provides background as this is
            // not based on ScrollViewKCM

            anchors.fill: sensorsView
            z: -1
        }

        clip: true
        reuseItems: true

        model: ListModel {
            Component.onCompleted: {
                JSON.parse(root.cfg_sensors).forEach((sensor) => append(sensor))
            }

            function save() {
                let sensors = []
                for (var i = 0; i < count; ++i) {
                    sensors.push(get(i))
                }
                root.cfg_sensors = JSON.stringify(sensors)
            }
        }

        delegate: Item {
            // Item required to make Kirigami.ListItemDragHandle work

            width: sensorsView.width
            implicitHeight: sensorDelegate.height

            Kirigami.SwipeListItem {
                id: sensorDelegate

                enabled: root.libAvailable
                //alternatingBackground: true // TODO: Doesn't work?

                RowLayout {
                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.ListItemDragHandle {
                        listItem: sensorDelegate
                        listView: sensorsView
                        onMoveRequested: (oldIndex, newIndex) => {
                            sensorsView.model.move(oldIndex, newIndex, 1)
                            sensorsView.model.save()
                        }
                    }

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: name
                    }
                }

                actions: [
                    Kirigami.Action {
                        text: i18n("Edit")
                        icon.name: "edit-entry"
                        onTriggered: editSensorSheet.openSensor(sensorsView.model.get(index))
                    },
                    Kirigami.Action {
                        text: i18n("Delete")
                        icon.name: "edit-delete-remove"
                        onTriggered: {
                            sensorsView.model.remove(index, 1)
                            sensorsView.model.save()
                        }
                    }
                ]
            }
        }
    }

    ColumnLayout {
        spacing: 0

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing

            enabled: root.libAvailable

            QQC2.Button {
                text: "Add Sensor…"
                icon.name: "list-add"
                onClicked: addSensorSheet.open()
            }

            Item {
                Layout.fillWidth: true
            }

            QQC2.Button {
                text: "Import…"
                icon.name: "document-import"
                onClicked: {}
            }

            QQC2.Button {
                text: "Export…"
                icon.name: "document-export"
                onClicked: {}
            }
        }
    }

    Kirigami.OverlaySheet {
        id: editSensorSheet

        property var editingSensor: null

        width:  Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 8

        title: "Edit Sensor"

        Kirigami.FormLayout {

            Kirigami.SelectableLabel {
                Kirigami.FormData.label: "Sensor:"

                text: editSensorSheet.editingSensor?.sensorId || ""
            }

            QQC2.TextField {
                id: sensorNameField

                Kirigami.FormData.label: "Name:"

                onTextChanged: {
                    editSensorSheet.editingSensor.name = text
                    sensorsView.model.save()
                }
            }
        }

        onEditingSensorChanged: {
            sensorNameField.text = editSensorSheet.editingSensor.name
        }

        function openSensor(sensor) {
            editingSensor = sensor
            open()
        }
    }

    Kirigami.OverlaySheet {
        id: addSensorSheet

        width:  Kirigami.Units.gridUnit * 20
        height: Kirigami.Units.gridUnit * 16

        title: "Add Sensor"

        ListView {
            property alias availableSensors: availableSensorsLoader.item

            Loader {
                id: availableSensorsLoader

                Component.onCompleted: setSource("AvailableSensorsProxy.qml")
            }

            reuseItems: true

            model: availableSensors?.availableSensorsModel

            section {
                property: "section"
                delegate: Kirigami.ListSectionHeader {
                    required property string section
                    text: section
                }
            }

            delegate: Kirigami.SwipeListItem {
                id: sensorDelegate

                QQC2.Label {
                    text: model.name
                }

                actions: [
                    Kirigami.Action {
                        text: i18n("Add")
                        icon.name: "list-add"
                        onTriggered: {
                            sensorsView.model.append({"name": model.name, "sensorId": model.sensorId})
                            sensorsView.model.save()
                        }
                    }
                ]
            }
        }
    }
}