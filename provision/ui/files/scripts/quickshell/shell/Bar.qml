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
import Quickshell.Wayland
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
                property bool showPreview: false

                Timer {
                    id: hideTimer
                    interval: 100
                    onTriggered: wsButton.showPreview = false
                }

                Layout.fillHeight: true
                implicitWidth: 24

                color: isUrgent ? Theme.iris
                     : isActive ? Theme.highlightHigh
                     : showPreview ? Theme.pine
                     : "transparent"

                // Active workspace bottom accent
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: 3
                    visible: isActive || showPreview
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
                    onContainsMouseChanged: {
                        if (containsMouse) {
                            hideTimer.stop()
                            wsButton.showPreview = true
                        } else {
                            hideTimer.restart()
                        }
                    }
                }

                LazyLoader {
                    id: previewLoader
                    active: wsButton.showPreview && (wsButton.isActive || wsButton.isOccupied)

                    PopupWindow {
                        visible: true
                        anchor {
                            window: bar
                            edges: Edges.Bottom
                            gravity: Edges.Bottom
                            rect.y: bar.implicitHeight
                        }

                        implicitWidth: 320
                        implicitHeight: 200
                        color: "transparent"

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onContainsMouseChanged: {
                                if (containsMouse) {
                                    hideTimer.stop()
                                } else {
                                    hideTimer.restart()
                                }
                            }
                        }

                        Rectangle {
                            id: previewBg
                            anchors.fill: parent
                            radius: 8
                            color: Qt.rgba(Theme.overlay.r, Theme.overlay.g, Theme.overlay.b, 0.9)
                            clip: true

                            opacity: 0
                            transform: Translate {
                                id: slideTransform
                                y: -20
                                Behavior on y {
                                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                                }
                            }

                            Component.onCompleted: {
                                opacity = 1
                                slideTransform.y = 0
                            }

                            Behavior on opacity {
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }

                            // Active workspace: full screen capture
                            ScreencopyView {
                                visible: wsButton.isActive
                                anchors.centerIn: parent
                                captureSource: bar.screen
                                live: true
                                constraintSize: Qt.size(previewBg.width - 16, previewBg.height - 16)
                            }

                            // Inactive occupied workspace: grid of window thumbnails
                            Grid {
                                visible: !wsButton.isActive && wsButton.isOccupied
                                anchors.centerIn: parent
                                spacing: 4
                                columns: {
                                    var count = wsButton.workspace ? wsButton.workspace.toplevels.values.length : 1
                                    return Math.max(1, Math.ceil(Math.sqrt(count)))
                                }

                                Repeater {
                                    model: (!wsButton.isActive && wsButton.isOccupied && wsButton.workspace)
                                           ? wsButton.workspace.toplevels.values : []

                                    ScreencopyView {
                                        required property var modelData
                                        captureSource: modelData.wayland
                                        live: true
                                        constraintSize: {
                                            var count = wsButton.workspace.toplevels.values.length
                                            var cols = Math.max(1, Math.ceil(Math.sqrt(count)))
                                            var rows = Math.max(1, Math.ceil(count / cols))
                                            var cellW = (previewBg.width - 16 - (cols - 1) * 4) / cols
                                            var cellH = (previewBg.height - 16 - (rows - 1) * 4) / rows
                                            return Qt.size(cellW, cellH)
                                        }
                                    }
                                }
                            }
                        }
                    }
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