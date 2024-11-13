/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import "../code/formatter.js" as Formatter

ColumnLayout {
    id: delegate

    property string sensorName
    property int sensorUnit

    property var sensorValue

    readonly property bool showUnit: Plasmoid.configuration.showUnit
    readonly property bool enableDangerColor: Plasmoid.configuration.enableDangerColor
    readonly property int warningThreshold: Plasmoid.configuration.warningThreshold
    readonly property int meltdownThreshold: Plasmoid.configuration.meltdownThreshold

    property bool swapLabels: Plasmoid.configuration.swapLabels
    property double fontScale: Plasmoid.configuration.fontScale

    spacing: 0

    PlasmaComponents.Label {
        id: primaryLabel
        Layout.alignment: Qt.AlignHCenter

        font: {
            let font = Object.assign({}, Kirigami.Theme.defaultFont);
            font.pointSize *= fontScale;
            font.pixelSize = undefined;
            font.features = { "tnum": 1 };
            return font;
        }

        text: swapLabels ? nameText() : temperatureText()
        color: swapLabels ? PlasmaCore.Theme.textColor : temperatureColor()

        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaComponents.Label {
        id: secondaryLabel
        Layout.alignment: Qt.AlignRight

        opacity: 0.6
        visible: text && root.height >= primaryLabel.contentHeight + contentHeight * 0.8

        font: {
            let font = Object.assign({}, Kirigami.Theme.smallFont);
            font.pointSize *= fontScale;
            font.pixelSize = undefined;
            font.features = { "tnum": 1 };
            return font;
        }

        text: swapLabels ? temperatureText() : nameText()
        color: swapLabels ? temperatureColor() : PlasmaCore.Theme.textColor

        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    function temperatureText() : string {
        return Formatter.formatTemperature(sensorValue, sensorUnit, showUnit);
    }

    function nameText() : string {
        if (sensorName === undefined) {
            return "—";
        }

        return sensorName;
    }

    function temperatureColor() : color {
        if (enableDangerColor && sensorValue !== undefined) {
            let temperature = Formatter.roundedTemperature(sensorValue);

            if (temperature >= meltdownThreshold) {
                return PlasmaCore.Theme.negativeTextColor;
            } else if (temperature >= warningThreshold) {
                return PlasmaCore.Theme.neutralTextColor;
            }
        }

        return PlasmaCore.Theme.textColor;
    }
}
