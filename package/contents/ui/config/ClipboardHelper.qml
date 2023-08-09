/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick

// TODO: Use kdeclarative Clipboard instead
// https://api.kde.org/frameworks/kdeclarative/html/classClipboard.html

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
