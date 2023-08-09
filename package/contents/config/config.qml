/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: WTFPL
*/

import QtQuick
import org.kde.plasma.configuration

ConfigModel {

    ConfigCategory {
         name: i18n("Sensors")
         icon: "temperature-normal"
         source: "config/ConfigSensors.qml"
         includeMargins: false
    }

    /*
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "config/ConfigAppearance.qml"
    }

    ConfigCategory {
         name: i18n("Misc")
         icon: "preferences-system-other"
         source: "config/ConfigMisc.qml"
    }
    */
}