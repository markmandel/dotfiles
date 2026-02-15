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
import Quickshell.Hyprland
import qs.Common

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: 23
    color: Theme.base

    // Bottom border to match waybar styling
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 3
        color: Theme.muted
    }

    Text {
        anchors.centerIn: parent
        color: Theme.text
        font.family: "JetBrains Mono"
        font.pixelSize: 10

        text: Hyprland.activeToplevel?.title ?? ""
    }
}