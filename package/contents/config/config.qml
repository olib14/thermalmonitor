/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import org.kde.plasma.configuration

ConfigModel {

    ConfigCategory {
         name: i18n("Sensors")
         icon: "temperature-warm"
         source: "config/ConfigSensors.qml"
    }

    ConfigCategory {
         name: i18n("Behavior")
         icon: "preferences-other"
         source: "config/ConfigBehavior.qml"
    }

    ConfigCategory {
         name: i18n("Appearance")
         icon: "preferences-desktop-color"
         source: "config/ConfigAppearance.qml"
    }
}
