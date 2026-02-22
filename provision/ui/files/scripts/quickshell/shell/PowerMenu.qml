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
import Quickshell.Io
import qs.Common

Rectangle {
    id: powerRoot
    required property PanelWindow barWindow

    Layout.fillHeight: true
    implicitWidth: powerIcon.implicitWidth
    color: powerHover.containsMouse ? Theme.highlightHigh : "transparent"
    radius: 2

    property bool menuOpen: false
    onMenuOpenChanged: {
        if (menuOpen) {
            _popupActive = true
            closeTimer.restart()
        } else {
            closeTimer.stop()
            // _popupActive = false is set by the close animation on completion
        }
    }

    // Separate from menuOpen so the popup isn't destroyed until close animation ends
    property bool _popupActive: false

    property bool popupHovered: false

    // Auto-close the menu if neither the button nor the popup is hovered for 5s
    Timer {
        id: closeTimer
        interval: 2000
        repeat: false
        onTriggered: powerRoot.menuOpen = false
    }

    // --- Processes (outside popup so they survive menu close) ---
    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: suspendProcess
        command: ["systemctl", "suspend"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    // --- Icon ---
    IconImage {
        id: powerIcon
        anchors.centerIn: parent
        implicitSize: 14
        source: "image://icon/system-shutdown-symbolic"
    }

    // --- Slide-down menu ---
    LazyLoader {
        active: powerRoot._popupActive

        PopupWindow {
            id: powerMenu
            visible: true
            anchor {
                window: powerRoot.barWindow
                edges: Edges.Bottom
                gravity: Edges.Bottom
                rect.y: powerRoot.barWindow.implicitHeight
            }
            // Pin 8px from screen right edge, matching bar RowLayout rightMargin
            anchor.rect.x: powerRoot.barWindow.width

            implicitWidth: 140
            // Start at 2 (not 0) — Wayland rejects zero-size surfaces
            implicitHeight: 2
            color: "transparent"

            // Flag distinguishes a natural close-animation finish from an
            // interrupted stop (e.g. user reopens before animation completes)
            property bool _animatingClose: false

            NumberAnimation {
                id: openAnim
                target: powerMenu
                property: "implicitHeight"
                to: 90
                duration: 200
                easing.type: Easing.OutCubic
            }

            NumberAnimation {
                id: closeAnim
                target: powerMenu
                property: "implicitHeight"
                to: 2
                duration: 200
                easing.type: Easing.InCubic
                onStopped: {
                    if (powerMenu._animatingClose) {
                        powerMenu._animatingClose = false
                        powerRoot._popupActive = false
                    }
                }
            }

            Connections {
                target: powerRoot
                function onMenuOpenChanged() {
                    if (powerRoot.menuOpen) {
                        // Clear flag BEFORE stop() so onStopped doesn't deactivate
                        powerMenu._animatingClose = false
                        closeAnim.stop()
                        openAnim.from = powerMenu.implicitHeight
                        openAnim.start()
                    } else {
                        openAnim.stop()
                        powerMenu._animatingClose = true
                        closeAnim.from = powerMenu.implicitHeight
                        closeAnim.start()
                    }
                }
            }

            Component.onCompleted: openAnim.start()

            // clip: true on Item (not Rectangle) so the animated window boundary
            // clips overflow without flattening the Rectangle's border-radius
            Item {
                anchors.fill: parent
                clip: true

                // Hover tracker for the popup — drives the auto-close timer.
                // acceptedButtons: Qt.NoButton makes it click-transparent so
                // button MouseAreas underneath still receive clicks.
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.NoButton
                    onContainsMouseChanged: {
                        powerRoot.popupHovered = containsMouse
                        if (!powerRoot.menuOpen) return
                        if (containsMouse) closeTimer.stop()
                        else if (!powerHover.containsMouse) closeTimer.restart()
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 90
                    radius: 4
                    color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b)
                    border.color: Theme.highlightMed
                    border.width: 1

                    Column {
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: 4
                        }
                        spacing: 2

                        // --- Shutdown ---
                        Rectangle {
                            width: parent.width
                            height: 26
                            radius: 2
                            color: shutdownHover.containsMouse ? Theme.highlightHigh : "transparent"

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                spacing: 6

                                IconImage {
                                    implicitSize: 12
                                    source: "image://icon/system-shutdown-symbolic"
                                }

                                Text {
                                    text: "Shutdown"
                                    color: Theme.text
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: shutdownHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    powerRoot.menuOpen = false
                                    shutdownProcess.running = true
                                }
                            }
                        }

                        // --- Suspend ---
                        Rectangle {
                            width: parent.width
                            height: 26
                            radius: 2
                            color: suspendHover.containsMouse ? Theme.highlightHigh : "transparent"

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                spacing: 6

                                IconImage {
                                    implicitSize: 12
                                    source: "image://icon/system-suspend-symbolic"
                                }

                                Text {
                                    text: "Suspend"
                                    color: Theme.text
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: suspendHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    powerRoot.menuOpen = false
                                    suspendProcess.running = true
                                }
                            }
                        }

                        // --- Reboot ---
                        Rectangle {
                            width: parent.width
                            height: 26
                            radius: 2
                            color: rebootHover.containsMouse ? Theme.highlightHigh : "transparent"

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 6
                                spacing: 6

                                IconImage {
                                    implicitSize: 12
                                    source: "image://icon/system-reboot-symbolic"
                                }

                                Text {
                                    text: "Reboot"
                                    color: Theme.text
                                    font.family: "JetBrains Mono"
                                    font.pixelSize: 10
                                }
                            }

                            MouseArea {
                                id: rebootHover
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    powerRoot.menuOpen = false
                                    rebootProcess.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- Mouse area ---
    MouseArea {
        id: powerHover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: powerRoot.menuOpen = !powerRoot.menuOpen
        onContainsMouseChanged: {
            if (!powerRoot.menuOpen) return
            if (containsMouse) closeTimer.stop()
            else if (!powerRoot.popupHovered) closeTimer.restart()
        }
    }
}
