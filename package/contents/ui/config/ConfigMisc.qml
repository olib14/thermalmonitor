/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

import "../../code/formatter.js" as Formatter

KCM.SimpleKCM {

    property double cfg_updateInterval
    property int cfg_temperatureUnit
    property int cfg_chartHistory

    // HACK: Present to suppress errors
    property string cfg_sensors
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
    property double cfg_updateIntervalDefault
    property int cfg_temperatureUnitDefault

    onCfg_updateIntervalChanged: {
        updateIntervalSpinBox.value = updateIntervalSpinBox.toInt(cfg_updateInterval);
    }

    onCfg_temperatureUnitChanged: {
        switch (cfg_temperatureUnit) {
            default:
            case Formatter.Units.Celsius:
                temperatureUnitGroup.checkedButton = temperatureUnitCelciusButton;
                break;
            case Formatter.Units.Fahrenheit:
                temperatureUnitGroup.checkedButton = temperatureUnitFahrenheitButton;
                break;
            case Formatter.Units.Kelvin:
                temperatureUnitGroup.checkedButton = temperatureUnitKelvinButton;
                break;
        }

        temperatureUnitChangedMessage.show();
    }

    onCfg_chartHistoryChanged: { chartHistorySpinBox.value = cfg_chartHistory; }

    Component.onCompleted: cfg_temperatureUnitChanged()

    ColumnLayout {

        spacing: Kirigami.Units.gridUnit

        Kirigami.FormLayout {
            Layout.fillWidth: true

            QQC2.ButtonGroup { id: temperatureUnitGroup }

            QQC2.RadioButton {
                id: temperatureUnitCelciusButton

                Kirigami.FormData.label: "Temperature unit:"
                QQC2.ButtonGroup.group: temperatureUnitGroup

                text: Formatter.unitString(Formatter.Units.Celsius, false)
                onCheckedChanged: if (checked) { cfg_temperatureUnit = Formatter.Units.Celsius; }
            }

            QQC2.RadioButton {
                id: temperatureUnitFahrenheitButton
                QQC2.ButtonGroup.group: temperatureUnitGroup

                text: Formatter.unitString(Formatter.Units.Fahrenheit, false)
                onCheckedChanged: if (checked) { cfg_temperatureUnit = Formatter.Units.Fahrenheit; }
            }

            QQC2.RadioButton {
                id: temperatureUnitKelvinButton
                QQC2.ButtonGroup.group: temperatureUnitGroup

                text: Formatter.unitString(Formatter.Units.Kelvin, false)
                onCheckedChanged: if (checked) { cfg_temperatureUnit = Formatter.Units.Kelvin; }
            }

            Item { Kirigami.FormData.isSection: true }

            RowLayout {
                Kirigami.FormData.label: "Update interval:"

                QQC2.SpinBox {
                    id: updateIntervalSpinBox

                    stepSize: toInt(0.5)
                    from: toInt(1)
                    to: toInt(5)

                    validator: DoubleValidator {
                        bottom: updateIntervalSpinBox.from
                        top: updateIntervalSpinBox.to
                        decimals: 1
                        notation: DoubleValidator.StandardNotation
                    }

                    textFromValue: (value, locale) => Number(fromInt(value)).toLocaleString(locale, 'f', 1)
                    valueFromText: (text, locale) => Math.round(toInt(Number.fromLocaleString(locale, text)))

                    onValueChanged: cfg_updateInterval = fromInt(value)

                    function toInt(value) {
                        return value * 10;
                    }

                    function fromInt(value) {
                        return value / 10;
                    }
                }

                QQC2.Label {
                    text: "seconds"
                }
            }

            Item { Kirigami.FormData.isSection: true }

            RowLayout {
                Kirigami.FormData.label: "Show history for:"

                QQC2.SpinBox {
                    id: chartHistorySpinBox

                    stepSize: 1
                    from: 10
                    to: 3600

                    validator: IntValidator {
                        bottom: chartHistorySpinBox.from
                        top: chartHistorySpinBox.to
                    }

                    textFromValue: (value, locale) => Number(value).toLocaleString(locale, 'f', 0)
                    valueFromText: (text, locale) => Number.fromLocaleString(locale, text)

                    onValueChanged: cfg_chartHistory = value
                }

                QQC2.Label {
                    text: "seconds"
                }
            }
        }

        Kirigami.InlineMessage {
            id: temperatureUnitChangedMessage
            Layout.fillWidth: true

            property bool firstOpen: true

            function show() {
                if (firstOpen) {
                    firstOpen = false;
                } else {
                    visible = true;
                }
            }

            visible: false
            showCloseButton: true
            type: Kirigami.MessageType.Information
            text: "It may be necessary to change the warning/meltdown threshold values and chart scale settings to match your preferred unit in <i>Appearance</i>."
        }
    }
}
