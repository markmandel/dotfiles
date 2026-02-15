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
import Quickshell.Services.Pipewire
import qs.Common

Scope {
	id: root

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio ?? null

		function onVolumeChanged() {
			if (!root.ready) return;
			root.shouldShowOsd = true;
			hideTimer.restart();
		}

		function onMutedChanged() {
			if (!root.ready) return;
			root.shouldShowOsd = true;
			hideTimer.restart();
		}
	}

	property bool ready: false
	property bool shouldShowOsd: false
	property real volume: Pipewire.defaultAudioSink?.audio.volume ?? 0
	property bool muted: Pipewire.defaultAudioSink?.audio.muted ?? false
	property string volumeIcon: muted ? "audio-volume-muted-symbolic"
		: volume < 0.33 ? "audio-volume-low-symbolic"
		: volume < 0.66 ? "audio-volume-medium-symbolic"
		: "audio-volume-high-symbolic"

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
		iconSource: Quickshell.iconPath(root.volumeIcon)
		value: root.volume
		barColor: Theme.love
	}
}
