/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQml.Models

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.ScrollViewKCM {
    id: root

    // KDE TODO: Header should have no margins to allow for banner usage, and should come with separators
    // KDE TODO: Header actions should be supported in Plasmoid settings
    // KDE TODO: No error should be emitted when a property does not exist in a config page

    property string cfg_sensors

    readonly property bool hasSensors: sensorsView.model.count
    readonly property bool libAvailable: availableSensorsLoader.status === Loader.Ready
    readonly property bool clipboardAvailable: clipboardLoader.status === Loader.Ready

    // HACK: Present to suppress errors
    property string cfg_sensorsDefault
    property bool cfg_showUnit
    property bool cfg_showUnitDefault
    property bool cfg_enableDangerColor
    property bool cfg_enableDangerColorDefault
    property int cfg_warningThreshold
    property int cfg_warningThresholdDefault
    property int cfg_meltdownThreshold
    property int cfg_meltdownThresholdDefault
    property bool cfg_swapLabels
    property bool cfg_swapLabelsDefault
    property double cfg_fontScale
    property double cfg_fontScaleDefault
    property double cfg_updateInterval
    property double cfg_updateIntervalDefault
    property int cfg_temperatureUnit
    property int cfg_temperatureUnitDefault

    // HACK: Provides footer separator
    extraFooterTopPadding: true

    header: ColumnLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.InlineMessage {
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

    view: ListView {
        id: sensorsView

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
                    height: parent.height

                    spacing: Kirigami.Units.largeSpacing

                    Kirigami.ListItemDragHandle {
                        Layout.leftMargin: Kirigami.Units.largeSpacing

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

    Loader {
        id: clipboardLoader

        Component.onCompleted: setSource("ClipboardProxy.qml")
    }

    footer: RowLayout {
        enabled: root.libAvailable
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            id: addSensorButton

            // HACK: Footer comes with margin
            Layout.leftMargin: Kirigami.Units.largeSpacing - 6

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
            // HACK: Footer comes with margin
            Layout.rightMargin: Kirigami.Units.largeSpacing - 6

            text: "Export"
            icon.name: "document-export-symbolic"
            enabled: root.clipboardAvailable
            onClicked: clipboardLoader.item.content = sensorsView.model.saveString()
        }
    }

    Kirigami.OverlaySheet {
        id: editSensorSheet

        property var editingSensor: null

        width:  Kirigami.Units.gridUnit * 20
        height: editSensorsForm.implicitHeight + Kirigami.Units.gridUnit * 3

        title: "Edit Sensor"

        Kirigami.FormLayout {
            id: editSensorsForm

            Kirigami.SelectableLabel {
                Kirigami.FormData.label: "Sensor:"
                Layout.fillWidth: true

                text: editSensorSheet.editingSensor?.sensorId || ""
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

        width:  sensorsView.width - Kirigami.Units.gridUnit * 4
        height: sensorsView.height - Kirigami.Units.gridUnit * 4

        title: "Add Sensor"

        ListView {
            id: addSensorsView

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
                    width: addSensorsView.width
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
                    height: parent.height

                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        Layout.leftMargin: Kirigami.Units.largeSpacing

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
