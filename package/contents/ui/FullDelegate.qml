/*
    SPDX-FileCopyrightText: 2024 Oliver Beard <olib141@outlook.com>
    SPDX-License-Identifier: MIT
*/

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami

import org.kde.quickcharts as Charts
import org.kde.quickcharts.controls as ChartsControls

import "../code/formatter.js" as Formatter

RowLayout {
    id: delegate

    property string sensorName
    property int sensorUnit

    property var sensorValue
    property var sensorHistory
    property var sensorAvg
    property var sensorMin
    property var sensorMax
    property var sensorGlobalMin
    property var sensorGlobalMax

    readonly property bool showUnit: Plasmoid.configuration.showUnit
    readonly property bool enableDangerColor: Plasmoid.configuration.enableDangerColor
    readonly property int warningThreshold: Plasmoid.configuration.warningThreshold
    readonly property int meltdownThreshold: Plasmoid.configuration.meltdownThreshold
    readonly property bool showStats: Plasmoid.configuration.showStats
    readonly property bool chartAutomaticScale: Plasmoid.configuration.chartAutomaticScale
    readonly property int chartFromY: Plasmoid.configuration.chartFromY
    readonly property int chartToY: Plasmoid.configuration.chartToY

    spacing: Kirigami.Units.smallSpacing

    RowLayout {

        visible: showStats

        spacing: Kirigami.Units.smallSpacing

        ColumnLayout {

            CompactDelegate {
                sensorName: "Avg"
                sensorUnit: delegate.sensorUnit
                sensorValue: sensorAvg
                swapLabels: false
                fontScale: 1
            }

            Item {
                Layout.fillHeight: true
            }

            CompactDelegate {
                sensorName: "Min"
                sensorUnit: delegate.sensorUnit
                sensorValue: sensorMin
                swapLabels: false
                fontScale: 1
            }

            CompactDelegate {
                sensorName: "Max"
                sensorUnit: delegate.sensorUnit
                sensorValue: sensorMax
                swapLabels: false
                fontScale: 1
            }
        }

        Kirigami.Separator {
            Layout.fillHeight: true
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.rightMargin: Kirigami.Units.smallSpacing
        }
    }

    RowLayout {
        Layout.fillHeight: true
        Layout.fillWidth: true

        spacing: Kirigami.Units.smallSpacing

        opacity: sensorHistory.ready ? 1 : 0

        ChartsControls.AxisLabels {
            Layout.fillHeight: true

            constrainToBounds: true
            direction: ChartsControls.AxisLabels.VerticalBottomTop

            delegate: PlasmaComponents.Label {
                anchors.right: parent.right

                font: {
                    let font = Object.assign({}, Kirigami.Theme.smallFont);
                    font.pixelSize = undefined;
                    font.features = { "tnum": 1 };
                    return font;
                }

                text: Formatter.formatTemperature(ChartsControls.AxisLabels.label, sensorUnit, showUnit)
                color: PlasmaCore.Theme.disabledTextColor
            }

            source: Charts.ChartAxisSource {
                chart: chart
                axis: Charts.ChartAxisSource.YAxis
                itemCount: lines.major.count + 2
            }
        }

        Charts.LineChart {
            id: chart
            Layout.fillWidth: true
            Layout.fillHeight: true

            property var color: {
                if (enableDangerColor && sensorValue !== undefined) {
                    let temperature = Formatter.roundedTemperature(sensorValue);

                    if (temperature >= meltdownThreshold) {
                        return PlasmaCore.Theme.negativeTextColor;
                    } else if (temperature >= warningThreshold) {
                        return PlasmaCore.Theme.neutralTextColor;
                    }
                }

                return PlasmaCore.Theme.highlightColor;
            }

            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }

            direction: Charts.XYChart.ZeroAtEnd
            interpolate: true
            valueSources: [sensorHistory]
            colorSource: Charts.ArraySource { array: [chart.color] }
            fillOpacity: 0.1

            yRange {
                automatic: false
                from: chartAutomaticScale ? toNearest(sensorGlobalMin - 15, 20) : chartFromY
                to: chartAutomaticScale ? toNearest(sensorGlobalMax + 15, 20) : chartToY
            }

            function toNearest(value, increment) {
                return Math.round(value / increment) * increment;
            }

            ChartsControls.GridLines {
                id: lines
                anchors.fill: chart

                z: -1
                chart: chart
                direction: ChartsControls.GridLines.Vertical
                major.count: {
                    let range = chart.yRange.to - chart.yRange.from;
                    let testValues = [1, 5, 10, 20, 25, 50, 100];
                    let counts = []

                    for (let i = 0; i < testValues.length; ++i) {
                        if (range % testValues[i] === 0) {
                            counts[i] = (range / testValues[i]) - 1;
                        } else {
                            counts[i] = Number.POSITIVE_INFINITY;
                        }
                    }

                    let countIndex = counts.findIndex(count => count <= 4);

                    if (countIndex === -1) {
                        countIndex = counts.findIndex(count => count <= 5);
                    }

                    if (countIndex === -1) {
                        return 4;
                    } else {
                        return counts[countIndex];
                    }
                }
                // The same color as a Kirigami.Separator
                major.color: Kirigami.ColorUtils.linearInterpolation(PlasmaCore.Theme.backgroundColor, PlasmaCore.Theme.textColor, 0.2)
                minor.visible: false
            }
        }
    }
}
