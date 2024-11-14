/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore

import "../code/formatter.js" as Formatter

PlasmoidItem {
    id: root

    property alias sensors: sensorsItem.sensors
    readonly property bool needsConfiguration: sensors.length === 0

    property int activeSensor: -1
    property int hoveredSensor: -1

    onSensorsChanged: {
        expanded = false;
    }

    onExpandedChanged: (expanded) => {
        if (!expanded) {
            activeSensor = -1;
        }
    }

    Sensors {
        id: sensorsItem
    }

    Plasmoid.backgroundHints: PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground

    preferredRepresentation: compactRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}

    hideOnWindowDeactivate: !Plasmoid.configuration.pinned
    toolTipMainText: {
        if (needsConfiguration || hoveredSensor === -1) {
            return Plasmoid.title;
        }

        return "%1 — %2".arg(sensors[hoveredSensor]?.name ?? "").arg(Plasmoid.title);
    }
    toolTipSubText: {
        if (needsConfiguration) {
            return "Click to configure";
        }

        if (hoveredSensor === -1) {
            return "";
        }

        let unit = sensors[hoveredSensor]?.unit ?? 0;
        let showUnit = Plasmoid.configuration.showUnit;
        return "Average\t%1\nMinimum\t%2\nMaximum\t%3" // NOTE: \t likely poor with translation
            .arg(Formatter.formatTemperature(sensors[hoveredSensor]?.avg ?? 0, unit, showUnit))
            .arg(Formatter.formatTemperature(sensors[hoveredSensor]?.min ?? 0, unit, showUnit))
            .arg(Formatter.formatTemperature(sensors[hoveredSensor]?.max ?? 0, unit, showUnit));
    }
}
