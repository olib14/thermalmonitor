/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: delegate

    property string name
    property string sensorId

    readonly property double updateRateLimit: Plasmoid.configuration.updateInterval
    readonly property int unit: Plasmoid.configuration.temperatureUnit

    readonly property bool showUnit: Plasmoid.configuration.showUnit
    readonly property bool enableDangerColor: Plasmoid.configuration.enableDangerColor
    readonly property int warningThreshold: Plasmoid.configuration.warningThreshold
    readonly property int meltdownThreshold: Plasmoid.configuration.meltdownThreshold
    readonly property bool swapLabels: Plasmoid.configuration.swapLabels

    property alias sensor: sensorLoader.item

    onUpdateRateLimitChanged: {
        if (sensor) { sensor.updateRateLimit = updateRateLimit * 1000; }
    }

    Layout.leftMargin:  Kirigami.Units.smallSpacing
    Layout.rightMargin: Kirigami.Units.smallSpacing
    Layout.alignment:   Qt.AlignHCenter | Qt.AlignVCenter

    spacing: 0

    Loader {
        id: sensorLoader

        Component.onCompleted: setSource("SensorProxy.qml", {
            "sensorId": sensorId,
            "updateRateLimit": updateRateLimit * 1000
        })
    }

    PlasmaComponents.Label {
        id: tempLabel

        Layout.alignment: Qt.AlignHCenter

        font: Kirigami.Theme.defaultFont
        text: swapLabels ? delegate.nameText() : delegate.temperatureText()

        color: swapLabels ? PlasmaCore.Theme.textColor : temperatureColor()

        Behavior on color {
            ColorAnimation {
                id: temperatureColorAnimation

                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    PlasmaComponents.Label {
        id: nameLabel

        Layout.alignment: Qt.AlignRight

        font: Kirigami.Theme.smallFont
        text: swapLabels ? delegate.temperatureText() : delegate.nameText()
        opacity: 0.6
        visible: text && root.height >= tempLabel.contentHeight + contentHeight * 0.8

        color: swapLabels ? temperatureColor() : PlasmaCore.Theme.textColor

        Behavior on color {
            ColorAnimation {
                id: nameColorAnimation

                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    function temperatureText() {
        if (delegate.sensor && delegate.sensor.value !== undefined) {
            switch (delegate.unit) {
                case 0:
                default:
                    return delegate.sensor.value.toFixed(0) + (delegate.showUnit ? " °C" : "");
                case 1:
                    return (delegate.sensor.value * 1.8 + 32).toFixed(0) + (delegate.showUnit ? " °F" : "");
                case 2:
                    return (delegate.sensor.value  + 273.15).toFixed(0) + (delegate.showUnit ? " K" : "");
            }
        } else {
            return "—";
        }
    }

    function nameText() {
        return delegate.name;
    }

    function temperatureColor() {
        if (enableDangerColor && delegate.sensor && delegate.sensor.value !== undefined) {
            let temperature = delegate.sensor.value;
            if (temperature >= delegate.meltdownThreshold) {
                return PlasmaCore.Theme.negativeTextColor;
            } else if (temperature >= delegate.warningThreshold) {
                return PlasmaCore.Theme.neutralTextColor;
            }
        }

        return PlasmaCore.Theme.textColor;
    }
}
