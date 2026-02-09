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
import QtQuick

FocusScope {
    id: overview

    anchors.fill: parent
    focus: true

    property string filterText: ""

    // Build a flat list of toplevels sorted by workspace id
    // (negative-id workspaces at the end), then by x position
    // within each workspace (left to right).
    property var sortedToplevels: {
        Hyprland.refreshToplevels()
        var result = []
        var tail = []
        var wsList = Hyprland.workspaces.values
        for (var i = 0; i < wsList.length; i++) {
            var dest = wsList[i].id < 0 ? tail : result
            var toplevels = Array.from(wsList[i].toplevels.values)
            toplevels.sort(function(a, b) {
                var ax = a.lastIpcObject && a.lastIpcObject.at ? a.lastIpcObject.at[0] : 0
                var bx = b.lastIpcObject && b.lastIpcObject.at ? b.lastIpcObject.at[0] : 0
                return ax - bx
            })
            for (var j = 0; j < toplevels.length; j++) {
                dest.push(toplevels[j])
            }
        }
        return result.concat(tail)
    }

    // Filter toplevels by search text (case-insensitive match on title or appId)
    property var filteredToplevels: {
        var query = overview.filterText.toLowerCase()
        if (query === "") return overview.sortedToplevels
        var result = []
        for (var i = 0; i < overview.sortedToplevels.length; i++) {
            var tl = overview.sortedToplevels[i]
            var title = (tl.title || "").toLowerCase()
            var appId = (tl.appId || "").toLowerCase()
            if (title.indexOf(query) >= 0 || appId.indexOf(query) >= 0) {
                result.push(tl)
            }
        }
        return result
    }

    onFilterTextChanged: navigateTo(0)

    property int padding: 32
    property int gap: 12
    property int filterHeight: 40
    property int count: repeater.count
    property real availW: width - padding * 2
    property real availH: height - padding * 2 - filterHeight - gap
    property int cols: Math.max(1, Math.ceil(Math.sqrt(count * (availW / Math.max(1, availH)))))
    property int rows: Math.max(1, Math.ceil(count / cols))
    property real cardW: (availW - gap * (cols - 1)) / cols
    property real cardH: (availH - gap * (rows - 1)) / rows

    function focusedIndex() {
        for (var i = 0; i < repeater.count; i++) {
            var item = repeater.itemAt(i)
            if (item && item.activeFocus) return i
        }
        return -1
    }

    function navigateTo(idx) {
        if (repeater.count === 0) return
        var clamped = Math.max(0, Math.min(idx, repeater.count - 1))
        var item = repeater.itemAt(clamped)
        if (item) item.forceActiveFocus()
    }

    Keys.onEscapePressed: {
        if (overview.filterText !== "") {
            overview.filterText = ""
        } else {
            Qt.quit()
        }
    }
    Keys.onLeftPressed: { var i = focusedIndex(); navigateTo(i > 0 ? i - 1 : 0) }
    Keys.onRightPressed: { var i = focusedIndex(); navigateTo(i >= 0 ? i + 1 : 0) }
    Keys.onUpPressed: { var i = focusedIndex(); navigateTo(i >= cols ? i - cols : i) }
    Keys.onDownPressed: { var i = focusedIndex(); navigateTo(i >= 0 ? i + cols : 0) }

    // Capture typing for the filter
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Backspace) {
            overview.filterText = overview.filterText.slice(0, -1)
            event.accepted = true
        } else if (event.text && event.text.length === 1
                   && event.key !== Qt.Key_Return
                   && event.key !== Qt.Key_Enter
                   && event.key !== Qt.Key_Escape) {
            overview.filterText += event.text
            event.accepted = true
        }
    }

    Component.onCompleted: navigateTo(0)

    // Filter bar
    Rectangle {
        id: filterBar
        x: overview.padding
        y: overview.padding
        width: overview.availW
        height: overview.filterHeight
        radius: 8
        color: Theme.surface
        border.color: overview.filterText !== "" ? Theme.love : Theme.highlightMed
        border.width: 1

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 12
            text: overview.filterText !== "" ? overview.filterText : "Type to filter..."
            color: overview.filterText !== "" ? Theme.text : Theme.muted
            font.pixelSize: 14
            elide: Text.ElideRight
        }

        // Blinking cursor
        Rectangle {
            visible: overview.filterText !== ""
            anchors.verticalCenter: parent.verticalCenter
            x: filterLabel.implicitWidth + 12
            width: 1
            height: 16
            color: Theme.text
            opacity: cursorAnim.running ? 1 : 0

            Text {
                id: filterLabel
                visible: false
                text: overview.filterText
                font.pixelSize: 14
            }

            SequentialAnimation on opacity {
                id: cursorAnim
                running: overview.filterText !== ""
                loops: Animation.Infinite
                NumberAnimation { to: 1; duration: 200 }
                NumberAnimation { to: 0; duration: 200 }
            }
        }
    }

    Grid {
        id: grid
        x: overview.padding
        y: overview.padding + overview.filterHeight + overview.gap
        columns: overview.cols
        spacing: overview.gap

        move: Transition {
            NumberAnimation { properties: "x,y"; duration: 50; easing.type: Easing.OutCubic }
        }

        Repeater {
            id: repeater
            model: overview.filteredToplevels

            WindowCard {
                required property var modelData
                toplevel: modelData
                width: overview.cardW
                height: overview.cardH

                Behavior on width { NumberAnimation { duration: 50; easing.type: Easing.OutCubic } }
                Behavior on height { NumberAnimation { duration: 50; easing.type: Easing.OutCubic } }
            }
        }
    }
}
