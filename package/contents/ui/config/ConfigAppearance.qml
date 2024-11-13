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

    property bool cfg_showUnit
    property bool cfg_enableDangerColor
    property int cfg_warningThreshold
    property int cfg_meltdownThreshold
    property bool cfg_swapLabels
    property double cfg_fontScale
    property bool cfg_showStats
    property bool cfg_chartAutomaticScale
    property int cfg_chartFromY
    property int cfg_chartToY

    // HACK: Suppresses errors
    // https://invent.kde.org/plasma/plasma-desktop/-/merge_requests/2619
    property bool cfg_pinned
    property bool cfg_pinnedDefault
    property string cfg_lastSeenVersion
    property string cfg_lastSeenVersionDefault
    property string cfg_sensors
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
    property bool cfg_showUnitDefault
    property bool cfg_enableDangerColorDefault
    property int cfg_warningThresholdDefault
    property int cfg_meltdownThresholdDefault
    property bool cfg_swapLabelsDefault
    property double cfg_fontScaleDefault
    property bool cfg_showStatsDefault
    property bool cfg_chartAutomaticScaleDefault
    property int cfg_chartFromYDefault
    property int cfg_chartToYDefault

    Kirigami.FormLayout {

        Item {
            Kirigami.FormData.label: "General"
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showUnitBox
            Kirigami.FormData.label: "Temperature:"

            text: "Show unit"
            checked: cfg_showUnit
            onCheckedChanged: cfg_showUnit = checked
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: enableDangerColorBox

            text: "Enable danger color"
            checked: cfg_enableDangerColor
            onCheckedChanged: cfg_enableDangerColor = checked
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
                id: warningThresholdLabel
                Layout.leftMargin: enableDangerColorBox.indicator.width
                Layout.preferredWidth: Math.max(warningThresholdLabel.implicitWidth,
                                                meltdownThresholdLabel.implicitWidth)
                text: "Warning threshold:"
            }

            QQC2.SpinBox {
                id: warningThresholdSpinBox

                enabled: cfg_enableDangerColor

                stepSize: 10
                from: 0
                to: 400

                validator: IntValidator {
                    bottom: warningThresholdSpinBox.from
                    top: warningThresholdSpinBox.to
                }

                textFromValue: (value, locale) => Number(value).toLocaleString(locale, 'f', 0)
                valueFromText: (text, locale) => Number.fromLocaleString(locale, text)

                value: cfg_warningThreshold
                onValueChanged: cfg_warningThreshold = value
            }

            QQC2.Label {
                text: Formatter.unitString(cfg_temperatureUnit, false)
            }
        }

        RowLayout {

            QQC2.Label {
                id: meltdownThresholdLabel
                Layout.leftMargin: enableDangerColorBox.indicator.width
                Layout.preferredWidth: Math.max(warningThresholdLabel.implicitWidth,
                                                meltdownThresholdLabel.implicitWidth)
                text: "Meltdown threshold:"
            }

            QQC2.SpinBox {
                id: meltdownThresholdSpinBox

                enabled: cfg_enableDangerColor

                stepSize: 10
                from: 0
                to: 400

                validator: IntValidator {
                    bottom: meltdownThresholdSpinBox.from
                    top: meltdownThresholdSpinBox.to
                }

                textFromValue: (value, locale) => Number(value).toLocaleString(locale, 'f', 0)
                valueFromText: (text, locale) => Number.fromLocaleString(locale, text)

                value: cfg_meltdownThreshold
                onValueChanged: cfg_meltdownThreshold = value
            }

            QQC2.Label {
                text: Formatter.unitString(cfg_temperatureUnit, false)
            }
        }

        Item {
            Kirigami.FormData.label: "Applet"
            Kirigami.FormData.isSection: true
        }

        QQC2.ButtonGroup {
            id: primaryLabelGroup
        }

        QQC2.RadioButton {
            id: primaryLabelTemperatureButton
            Kirigami.FormData.label: "Primary label:"

            text: "Temperature"
            checked: !cfg_swapLabels
            onCheckedChanged: if (checked) cfg_swapLabels = false
        }

        QQC2.RadioButton {
            id: primaryLabelNameButton

            text: "Name"
            checked: cfg_swapLabels
            onCheckedChanged: if (checked) cfg_swapLabels = true
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.SpinBox {
            id: fontScaleSpinBox
            Kirigami.FormData.label: "Font scale:"

            stepSize: toInt(0.1)
            from: toInt(0.5)
            to: toInt(5)

            validator: DoubleValidator {
                bottom: fontScaleSpinBox.from
                top: fontScaleSpinBox.to
                decimals: 1
                notation: DoubleValidator.StandardNotation
            }

            textFromValue: (value, locale) => Number(fromInt(value)).toLocaleString(locale, 'f', 1)
            valueFromText: (text, locale) => Math.round(toInt(Number.fromLocaleString(locale, text)))

            value: toInt(cfg_fontScale)
            onValueChanged: { cfg_fontScale = fromInt(value); }

            function toInt(value: double) : int {
                return value * 10;
            }

            function fromInt(value: int) : double {
                return value / 10;
            }
        }

        Item {
            Kirigami.FormData.label: "Popup"
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: showStatsBox
            Kirigami.FormData.label: "Statistics:"

            text: "Show average, min and max temperatures"
            checked: cfg_showStats
            onCheckedChanged: cfg_showStats = checked
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: chartAutomaticScaleBox
            Kirigami.FormData.label: "Chart:"

            text: "Automatic scale"
            checked: cfg_chartAutomaticScale
            onCheckedChanged: cfg_chartAutomaticScale = checked
        }

        RowLayout {

            QQC2.Label {
                id: chartFromYLabel
                Layout.leftMargin: chartAutomaticScaleBox.indicator.width
                Layout.preferredWidth: Math.max(chartFromYLabel.implicitWidth,
                                                chartToYLabel.implicitWidth)
                text: "From:"
            }

            QQC2.SpinBox {
                id: chartFromYSpinBox
                Layout.preferredWidth: Math.max(chartFromYSpinBox.implicitWidth,
                                                chartToYSpinBox.implicitWidth)

                enabled: !cfg_chartAutomaticScale

                stepSize: 10
                from: 0
                to: chartToYSpinBox.value - 10

                validator: IntValidator {
                    bottom: chartFromYSpinBox.from
                    top: chartFromYSpinBox.to
                }

                textFromValue: (value, locale) => Number(value).toLocaleString(locale, 'f', 0)
                valueFromText: (text, locale) => Number.fromLocaleString(locale, text)

                value: cfg_chartFromY
                onValueChanged: cfg_chartFromY = value
            }

            QQC2.Label {
                text: Formatter.unitString(cfg_temperatureUnit, false)
            }
        }

        RowLayout {

            QQC2.Label {
                id: chartToYLabel
                Layout.leftMargin: chartAutomaticScaleBox.indicator.width
                Layout.preferredWidth: Math.max(chartFromYLabel.implicitWidth,
                                                chartToYLabel.implicitWidth)
                text: "To:"
            }

            QQC2.SpinBox {
                id: chartToYSpinBox
                Layout.preferredWidth: Math.max(chartFromYSpinBox.implicitWidth,
                                                chartToYSpinBox.implicitWidth)

                enabled: !cfg_chartAutomaticScale

                stepSize: 10
                from: chartFromYSpinBox.value + 10
                to: 400

                validator: IntValidator {
                    bottom: chartToYSpinBox.from
                    top: chartToYSpinBox.to
                }

                textFromValue: (value, locale) => Number(value).toLocaleString(locale, 'f', 0)
                valueFromText: (text, locale) => Number.fromLocaleString(locale, text)

                value: cfg_chartToY
                onValueChanged: cfg_chartToY = value
            }

            QQC2.Label {
                text: Formatter.unitString(cfg_temperatureUnit, false)
            }
        }
    }
}
