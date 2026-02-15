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
import Quickshell.Services.SystemTray
import qs.Common

Rectangle {
    id: trayItem
    required property var modelData
    required property PanelWindow barWindow

    Layout.fillHeight: true
    implicitWidth: 18
    color: trayHover.containsMouse ? Theme.highlightHigh : "transparent"
    radius: 2

    IconImage {
        anchors.centerIn: parent
        implicitSize: 14
        source: trayItem.modelData.icon
    }

    LazyLoader {
        active: trayHover.containsMouse && (trayItem.modelData.tooltipTitle !== "" || trayItem.modelData.title !== "")

        PopupWindow {
            visible: true
            anchor {
                window: barWindow
                edges: Edges.Bottom
                gravity: Edges.Bottom
                rect.y: barWindow.implicitHeight
            }

            anchor.rect.x: trayItem.mapToItem(null, 0, 0).x

            implicitWidth: tooltipText.implicitWidth + 16
            implicitHeight: tooltipText.implicitHeight + (tooltipDesc.visible ? tooltipDesc.implicitHeight + 4 : 0) + 12
            color: "transparent"

            Rectangle {
                anchors.fill: parent
                radius: 4
                color: Qt.rgba(Theme.surface.r, Theme.surface.g, Theme.surface.b, 0.95)
                border.color: Theme.highlightMed
                border.width: 1

                Column {
                    anchors.centerIn: parent
                    spacing: 2

                    Text {
                        id: tooltipText
                        text: trayItem.modelData.tooltipTitle || trayItem.modelData.title
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 10
                    }

                    Text {
                        id: tooltipDesc
                        visible: trayItem.modelData.tooltipDescription !== ""
                        text: trayItem.modelData.tooltipDescription
                        color: Theme.text
                        font.family: "JetBrains Mono"
                        font.pixelSize: 9
                    }
                }
            }
        }
    }

    MouseArea {
        id: trayHover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

        onClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (trayItem.modelData.onlyMenu && trayItem.modelData.hasMenu) {
                    trayItem.modelData.display(barWindow, trayItem.mapToItem(null, 0, 0).x, barWindow.implicitHeight)
                } else {
                    trayItem.modelData.activate()
                }
            } else if (mouse.button === Qt.RightButton) {
                if (trayItem.modelData.hasMenu) {
                    trayItem.modelData.display(barWindow, trayItem.mapToItem(null, 0, 0).x, barWindow.implicitHeight)
                }
            } else if (mouse.button === Qt.MiddleButton) {
                trayItem.modelData.secondaryActivate()
            }
        }

        onWheel: function(wheel) {
            trayItem.modelData.scroll(
                wheel.angleDelta.y !== 0 ? wheel.angleDelta.y / 120 : wheel.angleDelta.x / 120,
                wheel.angleDelta.y === 0
            )
        }
    }
}
