/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami

Kirigami.Dialog {
    id: dialog

    property alias sensorId: idLabel.text
    property alias name: nameField.text

    title: "Edit Sensor"

    padding: Kirigami.Units.largeSpacing

    showCloseButton: false
    standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel

    Kirigami.FormLayout {
        Kirigami.SelectableLabel {
            id: idLabel
            Kirigami.FormData.label: "Sensor:"
        }

        QQC2.TextField {
            id: nameField
            Kirigami.FormData.label: "Name:"
        }
    }
}
