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

    Connections {
        target: Kirigami.Theme

        function onDefaultFontChanged() { updateFontSize(); }
        function onSmallFontChanged() { updateFontSize(); }
    }

    onFontScaleChanged: updateFontSize()

    spacing: 0

    PlasmaComponents.Label {
        id: primaryLabel
        Layout.alignment: Qt.AlignHCenter

        font: Kirigami.Theme.defaultFont

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

        font: Kirigami.Theme.smallFont
        opacity: 0.6
        visible: text && root.height >= primaryLabel.contentHeight + contentHeight * 0.8

        text: swapLabels ? temperatureText() : nameText()
        color: swapLabels ? temperatureColor() : PlasmaCore.Theme.textColor

        Behavior on color {
            ColorAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    function updateFontSize() {
        primaryLabel.font = Kirigami.Theme.defaultFont
        primaryLabel.font.pointSize = Kirigami.Theme.defaultFont.pointSize * fontScale
        secondaryLabel.font = Kirigami.Theme.smallFont
        secondaryLabel.font.pointSize = Kirigami.Theme.smallFont.pointSize * fontScale
    }

    function temperatureText() {
        if (sensorValue === undefined) {
            return "—";
        }

        return Formatter.formatTemperature(sensorValue, sensorUnit, showUnit);
    }

    function nameText() {
        if (sensorName === undefined) {
            return "—";
        }

        return sensorName;
    }

    function temperatureColor() {
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
