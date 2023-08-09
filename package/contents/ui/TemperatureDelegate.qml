/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: delegate

    // TODO: synchronise widths between delegates?
    // TODO: synchronise nameLabel visibility between delegates (when one, all)

    // TODO: Reserve space for 100 *C and center within it

    property string name
    property string sensorId
    property alias sensor: sensorLoader.item

    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

    spacing: 0

    Loader {
        id: sensorLoader

        Component.onCompleted: setSource("SensorProxy.qml", { "sensorId": sensorId })
    }

    PlasmaComponents.Label {
        id: tempLabel

        Layout.alignment: Qt.AlignHCenter

        font: Kirigami.Theme.defaultFont
        text: {
            if (sensor && sensor.value !== undefined) {
                return sensor.value.toFixed(0) + " °C"
            } else {
                return "-"
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
