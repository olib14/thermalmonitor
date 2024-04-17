/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {

    property bool cfg_showUnit
    property bool cfg_enableDangerColor
    property int cfg_warningThreshold
    property int cfg_meltdownThreshold
    property bool cfg_swapLabels
    property double cfg_fontScale

    // HACK: Present to suppress errors
    property string cfg_sensors
    property string cfg_sensorsDefault
    property bool cfg_showUnitDefault
    property bool cfg_enableDangerColorDefault
    property int cfg_warningThresholdDefault
    property int cfg_meltdownThresholdDefault
    property bool cfg_swapLabelsDefault
    property double cfg_fontScaleDefault
    property double cfg_updateInterval
    property double cfg_updateIntervalDefault
    property int cfg_temperatureUnit
    property int cfg_temperatureUnitDefault

    onCfg_showUnitChanged: { showUnitBox.checked = cfg_showUnit; }
    onCfg_enableDangerColorChanged: { enableDangerColorBox.checked = cfg_enableDangerColor; }
    onCfg_warningThresholdChanged: { warningThresholdSpinBox.value = cfg_warningThreshold; }
    onCfg_meltdownThresholdChanged: { meltdownThresholdSpinBox.value = cfg_meltdownThreshold; }
    onCfg_swapLabelsChanged: {
        primaryLabelTemperatureButton.checked = !cfg_swapLabels;
        primaryLabelNameButton.checked = cfg_swapLabels;
    }
    onCfg_fontScaleChanged: { fontScaleSpinBox.value = fontScaleSpinBox.toInt(cfg_fontScale) }

    Component.onCompleted: cfg_swapLabelsChanged()

    Kirigami.FormLayout {

        QQC2.CheckBox {
            id: showUnitBox
            Kirigami.FormData.label: "Temperature:"

            text: "Show unit"
            onCheckedChanged: { cfg_showUnit = checked; }
        }

        QQC2.CheckBox {
            id: enableDangerColorBox

            text: "Enable danger color"
            onCheckedChanged: { cfg_enableDangerColor = checked; }
        }

        QQC2.Label {
            Layout.fillWidth: true

            leftPadding: enableDangerColorBox.indicator.width
            text: "Change the color of the temperature label"
            textFormat: Text.PlainText
            elide: Text.ElideRight
            font: Kirigami.Theme.smallFont
        }

        RowLayout {
            QQC2.Label {
                Layout.leftMargin: enableDangerColorBox.indicator.width
                text: "Warning threshold:"
            }

            QQC2.SpinBox {
                id: warningThresholdSpinBox

                enabled: cfg_enableDangerColor

                stepSize: 1
                from: 0
                to: 150

                validator: IntValidator {
                    bottom: warningThresholdSpinBox.from
                    top: warningThresholdSpinBox.to
                }

                textFromValue: (value, locale) => {
                    return Number(value).toLocaleString(locale, 'f', 0) + " °C";
                }

                valueFromText: (text, locale) => {
                    return Number.fromLocaleString(locale, text.split(" ")[0]);
                }

                onValueChanged: { cfg_warningThreshold = value; }
            }
        }

        RowLayout {
            QQC2.Label {
                Layout.leftMargin: enableDangerColorBox.indicator.width
                text: "Meltdown threshold:"
            }

            QQC2.SpinBox {
                id: meltdownThresholdSpinBox

                enabled: cfg_enableDangerColor

                stepSize: 1
                from: 0
                to: 150

                validator: IntValidator {
                    bottom: meltdownThresholdSpinBox.from
                    top: meltdownThresholdSpinBox.to
                }

                textFromValue: (value, locale) => {
                    return Number(value).toLocaleString(locale, 'f', 0) + " °C";
                }

                valueFromText: (text, locale) => {
                    return Number.fromLocaleString(locale, text.split(" ")[0]);
                }

                onValueChanged: { cfg_meltdownThreshold = value; }
            }
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ButtonGroup { id: primaryLabelGroup }

        QQC2.RadioButton {
            id: primaryLabelTemperatureButton
            Kirigami.FormData.label: "Primary label:"

            text: "Temperature"
            onCheckedChanged: if (checked) cfg_swapLabels = false
        }

        QQC2.RadioButton {
            id: primaryLabelNameButton

            text: "Name"
            onCheckedChanged: if (checked) cfg_swapLabels = true
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.SpinBox {
            id: fontScaleSpinBox
            Kirigami.FormData.label: "Font scale:"

            stepSize: toInt(0.1)
            from: toInt(1)
            to: toInt(12)

            validator: DoubleValidator {
                bottom: fontScaleSpinBox.from
                top: fontScaleSpinBox.to
                decimals: 1
                notation: DoubleValidator.StandardNotation
            }

            textFromValue: (value, locale) => {
                return Number(fromInt(value)).toLocaleString(locale, 'f', 1);
            }

            valueFromText: (text, locale) => {
                return Math.round(toInt(Number.fromLocaleString(locale, text)));
            }

            onValueChanged: { cfg_fontScale = fromInt(value); }

            function toInt(value) {
                return value * 10;
            }

            function fromInt(value) {
                return value / 10;
            }
        }
    }
}
