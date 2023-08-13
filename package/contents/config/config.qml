/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick 2.15
import org.kde.plasma.configuration 2.0

ConfigModel {

    ConfigCategory {
         name: i18n("Sensors")
         icon: "temperature-normal"
         source: "config/ConfigSensors.qml"
    }

    /*
    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "config/ConfigAppearance.qml"
    }
    */

    ConfigCategory {
         name: i18n("Misc")
         icon: "preferences-system-other"
         source: "config/ConfigMisc.qml"
    }
}
