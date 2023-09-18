/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick 2.15
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2
import QtQml.Models 2.15

import org.kde.kirigami 2.20 as Kirigami

ColumnLayout {
    id: root

    property string cfg_sensors

    readonly property bool hasSensors: sensorsView.model.count
    readonly property bool libAvailable: availableSensorsLoader.status === Loader.Ready
    readonly property bool clipboardAvailable: clipboardLoader.status === Loader.Ready

    spacing: 0

    ColumnLayout {
        spacing: 0

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        Kirigami.InlineMessage {
            id: libBanner

            Layout.fillWidth: true

            visible: !root.libAvailable

            text: "The libraries <i>ksystemstats</i> (and <i>libksysguard</i>), <i>kitemmodels</i> are used to retrieve sensor data and are required to use this applet. Please ensure they are installed."
            type: Kirigami.MessageType.Error
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true

            visible: !root.clipboardAvailable

            text: "The library <i>kdeclarative</i> is required to export sensors to, and copy from, the  clipboard."
            type: Kirigami.MessageType.Warning
            showCloseButton: true
        }
    }

    Item {
        // Required so that OverlaySheet fills the ListView, as it uses the
        // parent's contentItem rather than just filling the parent

        Layout.fillWidth: true
        Layout.fillHeight: true

        ListView {
            id: sensorsView

            anchors.fill: parent

            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false

            Rectangle {
                // Provides background as this is
                // not based on ScrollViewKCM

                anchors.fill: sensorsView
                z: -1
                color: Kirigami.Theme.backgroundColor
            }

            clip: true
            reuseItems: true

            model: ListModel {
                id: sensorsModel

                Component.onCompleted: { loadString(root.cfg_sensors); }

                function loadString(string) {
                    let sensors = JSON.parse(string);
                    clear();
                    sensors.forEach((sensor) => append(sensor));
                    save();
                }

                function saveString() {
                    let sensors = [];
                    for (var i = 0; i < count; ++i) {
                        sensors.push(get(i));
                    }
                    return JSON.stringify(sensors);
                }

                function save() {
                    root.cfg_sensors = saveString();
                }
            }

            delegate: Item {
                // Item required to make Kirigami.ListItemDragHandle work

                width: sensorsView.width
                implicitHeight: sensorDelegate.height

                Kirigami.SwipeListItem {
                    id: sensorDelegate

                    enabled: root.libAvailable

                    RowLayout {
                        spacing: Kirigami.Units.largeSpacing

                        Kirigami.ListItemDragHandle {
                            listItem: sensorDelegate
                            listView: sensorsView
                            onMoveRequested: (oldIndex, newIndex) => {
                                sensorsView.model.move(oldIndex, newIndex, 1);
                                sensorsView.model.save();
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
                            icon.name: "edit-entry-symbolic"
                            onTriggered: editSensorSheet.openSensor(sensorsView.model.get(index))
                        },
                        Kirigami.Action {
                            text: i18n("Delete")
                            icon.name: "edit-delete-remove-symbolic"
                            onTriggered: {
                                sensorsView.model.remove(index, 1);
                                sensorsView.model.save();
                            }
                        }
                    ]
                }
            }

            Kirigami.PlaceholderMessage {
                anchors.centerIn: parent

                visible: root.libAvailable && !root.hasSensors

                icon.name: "temperature-normal"
                text: "No sensors"
                explanation: "Click <i>%1</i> to get started".arg(addSensorButton.text)
            }
        }

        Kirigami.OverlaySheet {
            id: editSensorSheet

            property var editingSensor: null

            title: "Edit Sensor"

            Kirigami.FormLayout {
                id: editSensorsForm

                Kirigami.SelectableLabel {
                    Kirigami.FormData.label: "Sensor:"
                    Layout.fillWidth: true

                    text: editSensorSheet.editingSensor.sensorId || ""
                }

                QQC2.TextField {
                    id: sensorNameField

                    Kirigami.FormData.label: "Name:"
                    Layout.fillWidth: true

                    onTextChanged: {
                        editSensorSheet.editingSensor.name = text;
                        sensorsView.model.save();
                    }
                }
            }

            onEditingSensorChanged: {
                sensorNameField.text = editSensorSheet.editingSensor.name;
            }

            function openSensor(sensor) {
                editingSensor = sensor;
                open();
            }
        }

        Kirigami.OverlaySheet {
            id: addSensorSheet

            title: "Add Sensor"

            ListView {
                property alias availableSensors: availableSensorsLoader.item

                Loader {
                    id: availableSensorsLoader

                    Component.onCompleted: setSource("AvailableSensorsProxy.qml")
                }

                reuseItems: true

                model: availableSensors.availableSensorsModel

                section {
                    property: "section"
                    delegate: Kirigami.ListSectionHeader {
                        required property string section
                        text: section
                    }
                }

                delegate: Kirigami.SwipeListItem {

                    // Disable when sensor is already present
                    enabled: {
                        for (var i = 0; i < sensorsModel.count; ++i) {
                            if (sensorsModel.get(i).sensorId === model.sensorId) {
                                return false;
                            }
                        }
                        return true;
                    }

                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.Label {
                            Layout.maximumWidth: parent.width

                            text: model.name
                            elide: Text.ElideRight

                            opacity: enabled ? 1 : 0.6

                            MouseArea {
                                id: sensorDelegateMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                            }
                        }

                        QQC2.Label {
                            Layout.fillWidth: true

                            font: Kirigami.Theme.smallFont
                            text: model.sensorId
                            elide: Text.ElideMiddle
                            opacity: (sensorDelegateMouseArea.containsMouse ? 0.6 : 0) * (enabled ? 1 : 0.6)

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Kirigami.Units.shortDuration
                                    easing.type: Easing.InOutQuad
                                }
                            }
                        }
                    }

                    actions: [
                        Kirigami.Action {
                            text: i18n("Add")
                            icon.name: "list-add-symbolic"
                            onTriggered: {
                                sensorsView.model.append({
                                    "name": model.name,
                                    "sensorId": model.sensorId
                                });
                                sensorsView.model.save();
                            }
                        }
                    ]
                }
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

            enabled: root.libAvailable

            QQC2.Button {
                id: addSensorButton

                text: "Add Sensor…"
                icon.name: "list-add-symbolic"
                onClicked: addSensorSheet.open()
            }

            Item {
                Layout.fillWidth: true
            }

            QQC2.Button {
                text: "Import"
                icon.name: "document-import-symbolic"
                enabled: root.clipboardAvailable
                onClicked: sensorsView.model.loadString(clipboardLoader.item.content)
            }

            QQC2.Button {
                text: "Export"
                icon.name: "document-export-symbolic"
                enabled: root.clipboardAvailable
                onClicked: clipboardLoader.item.content = sensorsView.model.saveString()
            }

            Loader {
                id: clipboardLoader
                visible: false
                Component.onCompleted: setSource("ClipboardProxy.qml")
            }
        }
    }
}
