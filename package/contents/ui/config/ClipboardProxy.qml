/*
    SPDX-FileCopyrightText: 2023 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import org.kde.kquickcontrolsaddons as KQuickControlsAddons

// Used in a Loader to make UI load when
// org.kde.kquickcontrolsaddons is not available

// e.g. loader.status !== Loader.Ready

KQuickControlsAddons.Clipboard {}
