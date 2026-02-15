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
import Quickshell.Hyprland
import Quickshell.Services.SystemTray
import qs.Common

PanelWindow {
    id: bar
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 20
    color: Theme.base

    // Bottom border
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 3
        color: Theme.muted
    }

    // Workspaces on the left
    RowLayout {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 2

        Repeater {
            model: 10

            WorkspaceButton { barWindow: bar }
        }
    }

    // Active window title in the center
    Text {
        anchors.centerIn: parent
        color: Theme.text
        font.family: "JetBrains Mono"
        font.pixelSize: 10

        text: Hyprland.activeToplevel?.title ?? ""
    }

    // Right side: system tray + clock
    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 6

        // System tray icons
        Repeater {
            model: SystemTray.items

            TrayIcon { barWindow: bar }
        }

        // Separator
        Rectangle {
            Layout.fillHeight: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            implicitWidth: 1
            color: Theme.highlightMed
        }

        Clock {}
    }
}
