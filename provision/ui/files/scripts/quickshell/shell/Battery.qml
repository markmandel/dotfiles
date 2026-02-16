/*
Copyright 2026 Mark Mandel All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.UPower
import qs.Common

Rectangle {
    id: batteryRoot
    required property PanelWindow barWindow

    Layout.fillHeight: true
    implicitWidth: contentRow.implicitWidth + 8
    color: batteryHover.containsMouse ? Theme.highlightHigh : "transparent"
    radius: 2

    Behavior on implicitWidth {
        NumberAnimation { duration: 150 }
    }

    // --- Data ---
    property UPowerDevice battery: UPower.displayDevice
    property bool isCharging: battery.state === UPowerDeviceState.Charging
    property bool isPlugged: !UPower.onBattery
    property bool isFull: battery.state === UPowerDeviceState.FullyCharged
    property real pct: battery.percentage * 100
    property bool isCritical: pct <= 10 && !isCharging

    // --- Helpers ---
    function formatTime(seconds: real): string {
        if (seconds <= 0) return "";
        var h = Math.floor(seconds / 3600);
        var m = Math.floor((seconds % 3600) / 60);
        return (h > 0 ? h + "h " : "") + m + "m";
    }

    function batteryIcon(): string {
        if (isFull) return "image://icon/battery-level-100-charged-symbolic";
        var level = Math.round(pct / 10) * 10;
        var suffix = isCharging ? "-charging-symbolic" : "-symbolic";
        return "image://icon/battery-level-" + level + suffix;
    }

    function iconColor(): color {
        if (isCritical) return Theme.love;
        if (isCharging || isFull || isPlugged) return Theme.foam;
        if (pct <= 30) return Theme.gold;
        return Theme.text;
    }

    function stateLabel(): string {
        if (isFull) return "Fully Charged";
        if (isCharging) return "Charging";
        if (isPlugged) return "Plugged In";
        return "On Battery";
    }

    // --- Pulsing animation for critical ---
    SequentialAnimation on opacity {
        running: batteryRoot.isCritical
        loops: Animation.Infinite
        NumberAnimation { to: 0.4; duration: 600 }
        NumberAnimation { to: 1.0; duration: 600 }
    }

    // --- Content ---
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        IconImage {
            implicitSize: 14
            source: batteryRoot.batteryIcon()
        }

        Text {
            visible: !batteryRoot.isCritical && !isFull
            text: Math.round(batteryRoot.pct) + "%"
            color: Theme.foam
            font.family: "JetBrains Mono"
            font.pixelSize: 10
        }

        Text {
            visible: batteryRoot.isCritical
            text: Math.round(batteryRoot.pct) + "% \u00b7 " + batteryRoot.formatTime(batteryRoot.battery.timeToEmpty)
            color: Theme.love
            font.family: "JetBrains Mono"
            font.pixelSize: 10
        }
    }

    // --- Tooltip ---
    LazyLoader {
        active: batteryHover.containsMouse

        PopupWindow {
            visible: true
            anchor {
                window: batteryRoot.barWindow
                edges: Edges.Bottom
                gravity: Edges.Bottom
                rect.y: batteryRoot.barWindow.implicitHeight
            }

            anchor.rect.x: batteryRoot.mapToItem(null, 0, 0).x

            implicitWidth: tooltipColumn.implicitWidth + 16
            implicitHeight: tooltipColumn.implicitHeight + 12
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.95)
                border.color: Theme.highlightMed
                border.width: 1

                Column {
                    id: tooltipColumn
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        text: batteryRoot.stateLabel()
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                    }

                    Text {
                        visible: batteryRoot.isCharging && batteryRoot.battery.timeToFull > 0
                        text: batteryRoot.formatTime(batteryRoot.battery.timeToFull) + " until full"
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                    }

                    Text {
                        visible: !batteryRoot.isCharging && !batteryRoot.isFull && batteryRoot.battery.timeToEmpty > 0
                        text: batteryRoot.formatTime(batteryRoot.battery.timeToEmpty) + " remaining"
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                    }

                    Text {
                        visible: batteryRoot.battery.healthPercentage > 0
                        text: "Battery health: " + Math.round(batteryRoot.battery.healthPercentage) + "%"
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                    }
                }
            }
        }
    }

    // --- Mouse area ---
    MouseArea {
        id: batteryHover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
