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
import Quickshell.Wayland
import qs.Common

Rectangle {
    id: caffeineRoot
    required property PanelWindow barWindow

    Layout.fillHeight: true
    implicitWidth: caffeineIcon.implicitWidth + 8
    color: caffeineHover.containsMouse ? Theme.highlightHigh : "transparent"
    radius: 2

    property bool inhibited: false

    IdleInhibitor {
        window: caffeineRoot.barWindow
        enabled: caffeineRoot.inhibited
    }

    IconImage {
        id: caffeineIcon
        anchors.centerIn: parent
        implicitSize: 14
        source: caffeineRoot.inhibited
            ? "image://icon/my-caffeine-on-symbolic"
            : "image://icon/my-caffeine-off-symbolic"
    }

    // --- Tooltip ---
    LazyLoader {
        active: caffeineHover.containsMouse

        PopupWindow {
            visible: true
            anchor {
                window: caffeineRoot.barWindow
                edges: Edges.Bottom
                gravity: Edges.Bottom
                rect.y: caffeineRoot.barWindow.implicitHeight
            }

            anchor.rect.x: caffeineRoot.mapToItem(null, 0, 0).x

            implicitWidth: tooltipText.implicitWidth + 16
            implicitHeight: tooltipText.implicitHeight + 12
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.95)
                border.color: Theme.highlightMed
                border.width: 1

                Text {
                    id: tooltipText
                    anchors.centerIn: parent
                    text: caffeineRoot.inhibited ? "Idle Inhibitor: On" : "Idle Inhibitor: Off"
                    color: Theme.text
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                }
            }
        }
    }

    // --- Mouse area ---
    MouseArea {
        id: caffeineHover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: caffeineRoot.inhibited = !caffeineRoot.inhibited
    }
}
