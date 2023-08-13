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
    property double updateRateLimit: Plasmoid.configuration.updateInterval
    property int unit: Plasmoid.configuration.temperatureUnit

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
        text: {
            if (sensor && sensor.value !== undefined) {
                switch(unit) {
                    default:
                    case 0:
                        return sensor.value.toFixed(0) + " °C";
                    case 1:
                        return (sensor.value * 1.8 + 32).toFixed(0) + " °F";
                    case 2:
                        return (sensor.value  + 273.15).toFixed(0) + " K";
                }
            } else {
                return "-";
            }
        }
    }

    PlasmaComponents.Label {
        id: nameLabel

        Layout.alignment: Qt.AlignRight

        font: Kirigami.Theme.smallFont
        text: delegate.name
        opacity: 0.6
        visible: text && root.height >= tempLabel.contentHeight + contentHeight * 0.8
    }
}
