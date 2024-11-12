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
import org.kde.kquickcontrolsaddons as KQuickControlsAddons

KCM.ScrollViewKCM {
    id: root

    property string cfg_sensors

    // HACK: Suppresses errors
    // https://invent.kde.org/plasma/plasma-desktop/-/merge_requests/2619
    property bool cfg_pinned
    property bool cfg_pinnedDefault
    property string cfg_lastSeenVersion
    property string cfg_lastSeenVersionDefault
    property string cfg_sensorsDefault
    property double cfg_updateInterval
    property double cfg_updateIntervalDefault
    property int cfg_temperatureUnit
    property int cfg_temperatureUnitDefault
    property int cfg_statsHistory
    property int cfg_statsHistoryDefault
    property bool cfg_scrollApplet
    property bool cfg_scrollAppletDefault
    property bool cfg_scrollAppletOpensPopup
    property bool cfg_scrollAppletOpensPopupDefault
    property bool cfg_scrollPopup
    property bool cfg_scrollPopupDefault
    property bool cfg_scrollWraparound
    property bool cfg_scrollWraparoundDefault
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
    property bool cfg_showStats
    property bool cfg_showStatsDefault
    property bool cfg_chartAutomaticScale
    property bool cfg_chartAutomaticScaleDefault
    property int cfg_chartFromY
    property int cfg_chartFromYDefault
    property int cfg_chartToY
    property int cfg_chartToYDefault

    readonly property bool hasSensors: sensorsView.model.count

    // HACK: Provides footer separator
    extraFooterTopPadding: true

    // HACK: Provides header separator
    Component.onCompleted: findHeaderSeparator().visible = true

    function findHeaderSeparator() {
        return root.header?.children[1] ?? null;
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
                        onTriggered: editSensorDialog.openSensor(sensorsView.model.get(index));
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

            visible: !root.hasSensors

            icon.name: "temperature-normal"
            text: "No sensors"
            explanation: "Click <i>%1</i> to get started".arg(addSensorButton.text)
        }
    }

    KQuickControlsAddons.Clipboard {
        id: clipboard
    }

    footer: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        QQC2.Button {
            id: addSensorButton

            // HACK: Footer comes with margin
            Layout.leftMargin: Kirigami.Units.largeSpacing - 6

            text: "Add Sensor…"
            icon.name: "list-add-symbolic"
            onClicked: addSensorDialog.open()
        }

        Item {
            Layout.fillWidth: true
        }

        QQC2.Button {
            text: "Import"
            icon.name: "document-import-symbolic"
            onClicked: sensorsView.model.loadString(clipboard.content)
        }

        QQC2.Button {
            // HACK: Footer comes with margin
            Layout.rightMargin: Kirigami.Units.largeSpacing - 6

            text: "Export"
            icon.name: "document-export-symbolic"
            onClicked: clipboard.content = sensorsView.model.saveString()
        }
    }

    AddSensorDialog {
        id: addSensorDialog

        width:  Math.min(implicitWidth, sensorsView.width  - Kirigami.Units.gridUnit * 2)
        height: Math.min(implicitHeight, sensorsView.height - Kirigami.Units.gridUnit * 2)

        addedSensorIds: Array.from({ length: sensorsModel.count }, (_, i) => sensorsModel.get(i).sensorId)

        onAddedSensor: (name, sensorId) => {
            sensorsView.model.append({
                "name": name,
                "sensorId": sensorId
            });
            sensorsView.model.save();
        }

        onRemovedSensor: (sensorId) => {
            for (var i = 0; i < sensorsModel.count; ++i) {
                if (sensorsModel.get(i).sensorId === sensorId) {
                    sensorsModel.remove(i);
                    break;
                }
            }
        }
    }

    EditSensorDialog {
        id: editSensorDialog

        property int index

        width:  Math.min(implicitWidth, sensorsView.width  - Kirigami.Units.gridUnit * 2)
        height: Math.min(implicitHeight, sensorsView.height - Kirigami.Units.gridUnit * 2)

        onAccepted: {
            sensorsModel.setProperty(index, "name", name);
        }

        function openSensor(index: int) : void {
            this.index = index;
            sensorId = sensorsModel.get(index).sensorId;

            name = sensorsModel.get(index).name;

            open();
        }
    }
}
