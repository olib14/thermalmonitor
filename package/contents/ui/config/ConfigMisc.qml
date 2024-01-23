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

    property double cfg_updateInterval
    property int cfg_temperatureUnit

    // HACK: Present to suppress errors
    property string cfg_sensors
    property string cfg_sensorsDefault
    property double cfg_updateIntervalDefault
    property int cfg_temperatureUnitDefault

    onCfg_updateIntervalChanged: {
        updateIntervalSpinBox.value = updateIntervalSpinBox.toInt(cfg_updateInterval);
    }

    onCfg_temperatureUnitChanged: {
        switch (cfg_temperatureUnit) {
            default:
            case 0:
                temperatureUnitGroup.checkedButton = temperatureUnitCelciusButton;
                break;
            case 1:
                temperatureUnitGroup.checkedButton = temperatureUnitFahrenheitButton;
                break;
            case 2:
                temperatureUnitGroup.checkedButton = temperatureUnitKelvinButton;
                break;
        }
    }

    Component.onCompleted: cfg_temperatureUnitChanged()

    Kirigami.FormLayout {

        QQC2.SpinBox {
            id: updateIntervalSpinBox

            Kirigami.FormData.label: "Update interval:"

            stepSize: toInt(0.1)
            from: toInt(1)
            to: toInt(5)

            validator: DoubleValidator {
                bottom: updateIntervalSpinBox.from
                top: updateIntervalSpinBox.to
                decimals: 1
                notation: DoubleValidator.StandardNotation
            }

            textFromValue: (value, locale) => {
                return Number(fromInt(value)).toLocaleString(locale, 'f', 1) + " s";
            }

            valueFromText: (text, locale) => {
                return Math.round(toInt(Number.fromLocaleString(locale, text.split(" ")[0])));
            }

            onValueChanged: cfg_updateInterval = fromInt(value)

            function toInt(value) {
                return value * 10;
            }

            function fromInt(value) {
                return value / 10;
            }
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ButtonGroup { id: temperatureUnitGroup }

        QQC2.RadioButton {
            id: temperatureUnitCelciusButton

            Kirigami.FormData.label: "Temperature unit:"
            QQC2.ButtonGroup.group: temperatureUnitGroup

            text: "°C"
            onCheckedChanged: if (checked) { cfg_temperatureUnit = 0; }
        }

        QQC2.RadioButton {
            id: temperatureUnitFahrenheitButton
            QQC2.ButtonGroup.group: temperatureUnitGroup

            text: "°F"
            onCheckedChanged: if (checked) { cfg_temperatureUnit = 1; }
        }

        QQC2.RadioButton {
            id: temperatureUnitKelvinButton
            QQC2.ButtonGroup.group: temperatureUnitGroup

            text: "K"
            onCheckedChanged: if (checked) { cfg_temperatureUnit = 2; }
        }
    }
}
