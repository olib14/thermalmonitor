/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick

TextEdit {
    visible: false

    function fromClipboard() {
        selectAll()
        paste()
        return text
    }

    function toClipboard(value) {
        text = value
        selectAll()
        copy()
    }
}
