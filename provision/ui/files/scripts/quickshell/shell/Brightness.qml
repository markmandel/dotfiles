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
import Quickshell
import Quickshell.Io
import qs.Common

Scope {
	id: root

	property bool ready: false
	property bool shouldShowOsd: false
	property real brightness: 0
	property string backlightPath: ""

	// Run brightnessctl -m to get device name and current brightness percentage.
	// Output format: device,class,current,percentage,max (e.g. "intel_backlight,backlight,3000,100%,3000")
	Process {
		id: brightnessProcess
		command: ["brightnessctl", "-m"]
		running: true
		stdout: SplitParser {
			onRead: data => {
				var fields = data.split(",")
				if (fields.length < 4) return;

				// Discover sysfs path from device name on first run
				if (root.backlightPath === "") {
					root.backlightPath = "/sys/class/backlight/" + fields[0] + "/brightness"
				}

				// Parse percentage (e.g. "100%") to 0–1
				root.brightness = parseInt(fields[3]) / 100

				if (root.ready) {
					root.shouldShowOsd = true;
					hideTimer.restart();
				}
			}
		}
	}

	// Watch sysfs brightness file purely as a change notifier
	FileView {
		path: root.backlightPath
		watchChanges: true
		onFileChanged: {
			brightnessProcess.running = true;
		}
	}

	Timer {
		id: readyTimer
		interval: 500
		running: true
		onTriggered: root.ready = true
	}

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	OsdBar {
		shouldShow: root.shouldShowOsd
		iconSource: Quickshell.iconPath("display-brightness-symbolic")
		value: root.brightness
		barColor: Theme.gold
	}
}
