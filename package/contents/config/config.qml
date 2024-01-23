/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import org.kde.plasma.configuration

ConfigModel {

    ConfigCategory {
         name: i18n("Sensors")
         icon: "temperature-normal"
         source: "config/ConfigSensors.qml"
    }

    ConfigCategory {
         name: i18n("Misc")
         icon: "preferences-system-other"
         source: "config/ConfigMisc.qml"
    }
}
