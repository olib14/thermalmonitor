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

    // TODO: Add pinned property defaults to false
    // override with binding when a config setting to remember pinned is checked
    // and set to the property and have that update it and whatever

    // Could go in a Behaviour settings page

    property list<QtObject> sensors: sensorsLoader.item?.sensors ?? []
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

    Loader {
        id: sensorsLoader

        source: "SensorProxy.qml"
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

        return "%1 — %2".arg(sensors[hoveredSensor].name).arg(Plasmoid.title);
    }
    toolTipSubText: {
        if (needsConfiguration) {
            return "Click to configure";
        }

        if (hoveredSensor === -1) {
            return "";
        }

        let unit = sensors[hoveredSensor].unit;
        let showUnit = Plasmoid.configuration.showUnit;
        return "Average\t%1\nMinimum\t%2\nMaximum\t%3" // NOTE: \t likely poor with translation
            .arg(Formatter.formatTemperature(sensors[hoveredSensor].avg, unit, showUnit))
            .arg(Formatter.formatTemperature(sensors[hoveredSensor].min, unit, showUnit))
            .arg(Formatter.formatTemperature(sensors[hoveredSensor].max, unit, showUnit));
    }

    Component.onCompleted: {
        let previousVersion = Plasmoid.configuration.lastSeenVersion;
        let currentVersion = Plasmoid.metadata.version;

        if (previousVersion != "") {
            // TODO: Upgrade!
            // Could work with array of versions and functions to upgrade,
            // run each matching function in order, do in ../code/upgrade.js
        }

        Plasmoid.configuration.lastSeenVersion = currentVersion;
    }
}
