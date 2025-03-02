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
    property int cfg_statsHistory
    property bool cfg_scrollApplet
    property bool cfg_scrollAppletOpensPopup
    property bool cfg_scrollPopup
    property bool cfg_scrollWraparound

    // HACK: Suppresses errors
    // https://invent.kde.org/plasma/plasma-desktop/-/merge_requests/2619
    property bool cfg_pinned
    property bool cfg_pinnedDefault
    property string cfg_lastSeenVersion
    property string cfg_lastSeenVersionDefault
    property string cfg_sensors
    property string cfg_sensorsDefault
    property double cfg_updateIntervalDefault
    property int cfg_temperatureUnitDefault
    property int cfg_statsHistoryDefault
    property bool cfg_scrollAppletDefault
    property bool cfg_scrollAppletOpensPopupDefault
    property bool cfg_scrollPopupDefault
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

    Kirigami.FormLayout {

        Item {
            Kirigami.FormData.label: "Sensor"
            Kirigami.FormData.isSection: true
        }

        QQC2.ButtonGroup {
            id: temperatureUnitGroup
        }

        QQC2.RadioButton {
            id: temperatureUnitCelciusButton

            Kirigami.FormData.label: "Temperature unit:"
            QQC2.ButtonGroup.group: temperatureUnitGroup

            text: Formatter.unitString(Formatter.Units.Celsius, false)
            checked: cfg_temperatureUnit == Formatter.Units.Celsius;
            onCheckedChanged: if (checked) { cfg_temperatureUnit = Formatter.Units.Celsius; }
        }

        QQC2.RadioButton {
            id: temperatureUnitFahrenheitButton
            QQC2.ButtonGroup.group: temperatureUnitGroup

            text: Formatter.unitString(Formatter.Units.Fahrenheit, false)
            checked: cfg_temperatureUnit == Formatter.Units.Fahrenheit;
            onCheckedChanged: if (checked) { cfg_temperatureUnit = Formatter.Units.Fahrenheit; }
        }

        /*
        QQC2.RadioButton {
            id: temperatureUnitKelvinButton
            QQC2.ButtonGroup.group: temperatureUnitGroup

            text: Formatter.unitString(Formatter.Units.Kelvin, false)
            checked: cfg_temperatureUnit == Formatter.Units.Kelvin;
            onCheckedChanged: if (checked) { cfg_temperatureUnit = Formatter.Units.Kelvin; }
        }
        */

        Item {
            Kirigami.FormData.isSection: true
        }

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

                value: toInt(cfg_updateInterval)
                onValueChanged: cfg_updateInterval = fromInt(value)

                function toInt(value: double) : int {
                    return value * 10;
                }

                function fromInt(value: int) : double {
                    return value / 10;
                }
            }

            QQC2.Label {
                text: "seconds"
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        RowLayout {
            Kirigami.FormData.label: "Show history for:"

            QQC2.SpinBox {
                id: statsHistorySpinBox

                stepSize: 1
                from: 10
                to: 3600

                validator: IntValidator {
                    bottom: statsHistorySpinBox.from
                    top: statsHistorySpinBox.to
                }

                textFromValue: (value, locale) => Number(value).toLocaleString(locale, 'f', 0)
                valueFromText: (text, locale) => Number.fromLocaleString(locale, text)

                value: cfg_statsHistory
                onValueChanged: cfg_statsHistory = value
            }

            QQC2.Label {
                text: "seconds"
            }
        }

        Item {
            Kirigami.FormData.label: "Miscellaneous"
            Kirigami.FormData.isSection: true
        }

        QQC2.CheckBox {
            id: scrollAppletBox
            Kirigami.FormData.label: "Scrolling:"

            text: "Scroll applet to change sensor"
            checked: cfg_scrollApplet
            onCheckedChanged: cfg_scrollApplet = checked
        }

        QQC2.CheckBox {
            id: scrollAppletOpensPopupBox

            leftPadding: scrollAppletBox.indicator.width

            enabled: scrollAppletBox.checked

            text: "Open popup on scroll"
            checked: cfg_scrollAppletOpensPopup
            onCheckedChanged: cfg_scrollAppletOpensPopup = checked
        }

        QQC2.CheckBox {
            id: scrollPopupBox

            text: "Scroll popup to change sensor"
            checked: cfg_scrollPopup
            onCheckedChanged: cfg_scrollPopup = checked
        }

        QQC2.CheckBox {
            id: scrollWraparoundBox

            text: "Wrap around"
            checked: cfg_scrollWraparound
            onCheckedChanged: cfg_scrollWraparound = checked
        }
    }
}
