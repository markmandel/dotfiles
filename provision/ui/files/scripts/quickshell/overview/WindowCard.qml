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

import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import qs.Common

Rectangle {
    id: card

    required property var toplevel

    property string windowTitle: toplevel.title || "Untitled"
    property string appId: toplevel.appId || ""
    property string wsLabel: toplevel.workspace ? "WS " + toplevel.workspace.id : ""
    property string address: toplevel.address || ""
    property int workspaceId: toplevel.workspace ? toplevel.workspace.id : 0
    property bool isActive: toplevel.activated || false

    signal selected()

    radius: 10
    color: activeFocus ? Theme.overlay : Theme.surface
    border.color: activeFocus ? Theme.foam : (isActive ? Theme.love : Theme.highlightMed)
    border.width: activeFocus || isActive ? 2 : 1

    focus: true
    Keys.onReturnPressed: card.selected()
    Keys.onSpacePressed: card.selected()

    // Live preview area
    Rectangle {
        id: previewArea
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: titleBar.top
        anchors.margins: 6
        radius: 6
        color: Theme.highlightLow
        clip: true

        ScreencopyView {
            id: preview
            captureSource: card.toplevel.wayland
            live: true
            anchors.centerIn: parent
            constraintSize: Qt.size(previewArea.width, previewArea.height)
        }

        // Fallback text when no content
        Text {
            anchors.centerIn: parent
            visible: !preview.hasContent
            text: card.appId || "?"
            color: Theme.highlightHigh
            font.pixelSize: Math.min(parent.width, parent.height) * 0.25
            font.bold: true
            font.capitalization: Font.AllUppercase
            opacity: 0.5
        }

        // Workspace badge
        Rectangle {
            visible: card.wsLabel !== ""
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 6
            width: wsText.implicitWidth + 12
            height: wsText.implicitHeight + 6
            radius: 4
            color: Qt.rgba(Theme.base.r, Theme.base.g, Theme.base.b, 0.8)

            Text {
                id: wsText
                anchors.centerIn: parent
                text: card.wsLabel
                color: Theme.subtle
                font.pixelSize: 10
                font.bold: true
            }
        }
    }

    // Title bar at bottom
    Item {
        id: titleBar
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 8
        height: titleText.implicitHeight + appText.implicitHeight + 2

        Column {
            anchors.fill: parent
            spacing: 2

            Text {
                id: titleText
                width: parent.width
                text: card.windowTitle
                color: Theme.text
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                id: appText
                width: parent.width
                text: card.appId
                color: Theme.muted
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: if (containsMouse) card.forceActiveFocus()
        onClicked: card.selected()
    }

    function activate() {
        if (card.workspaceId !== 0) {
            Hyprland.dispatch("focusworkspaceoncurrentmonitor " + card.workspaceId)
        }
        if (card.address !== "") {
            var addr = card.address.startsWith("0x") ? card.address : "0x" + card.address
            Hyprland.dispatch("focuswindow address:" + addr)
        } else {
            toplevel.activate()
        }
        Qt.quit()
    }

    onSelected: activate()
}
