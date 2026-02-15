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
import qs.Common

PanelWindow {
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

            Rectangle {
                id: wsButton
                required property int index

                property int wsId: index + 1
                property HyprlandWorkspace workspace: {
                    for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                        if (Hyprland.workspaces.values[i].id === wsId)
                            return Hyprland.workspaces.values[i];
                    }
                    return null;
                }
                property bool isActive: workspace?.focused ?? false
                property bool isOccupied: (workspace?.toplevels.values.length ?? 0) > 0
                property bool isUrgent: workspace?.urgent ?? false

                Layout.fillHeight: true
                implicitWidth: 24

                color: isUrgent ? Theme.iris
                     : isActive ? Theme.highlightHigh
                     : hoverArea.containsMouse ? Theme.pine
                     : "transparent"

                // Active workspace bottom accent
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    visible: isActive || hoverArea.containsMouse
                    color: isActive ? Theme.love : Theme.rose
                }

                Text {
                    anchors.centerIn: parent
                    text: wsId
                    font.family: "JetBrains Mono"
                    font.pixelSize: 10
                    color: !isOccupied && !isActive ? Theme.muted : Theme.text
                }

                MouseArea {
                    id: hoverArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }
            }
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
}