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

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.Common

Scope {
	property string iconSource
	property real value: 0
	property color barColor
	property bool shouldShow: false

	LazyLoader {
		active: shouldShow

		PanelWindow {
			anchors.bottom: true
			margins.bottom: screen.height / 15
			exclusiveZone: 0

			implicitWidth: 400
			implicitHeight: 50
			color: "transparent"

			// An empty click mask prevents the window from blocking mouse events.
			mask: Region {}

			Rectangle {
				anchors.fill: parent
				radius: height / 2
				color: Qt.rgba(Theme.overlay.r, Theme.overlay.g, Theme.overlay.b, 0.85)

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					IconImage {
						implicitSize: 30
						source: iconSource
					}

					Rectangle {
						Layout.fillWidth: true

						implicitHeight: 10
						radius: 20
						color: Theme.highlightMed

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}

							implicitWidth: parent.width * value
							radius: parent.radius
							color: barColor
						}
					}
				}
			}
		}
	}
}
