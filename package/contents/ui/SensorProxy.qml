/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import org.kde.ksysguard.sensors as Sensors

// Used in a Loader to make UI load when
// org.kde.ksysguard.sensors is not available

// e.g. loader.status !== Loader.Ready

Sensors.Sensor {}
