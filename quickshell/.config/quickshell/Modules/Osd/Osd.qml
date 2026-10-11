pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Hyprland
import Quickshell.Services.Mpris

import qs.Services

Scope {
    id: root

    property int bottomOffset: 90
    property int hideDelay: 1500
    property real step: 5               // brightness step in percent

    property bool ready: false          // ignore the initial values at startup
    property bool shown: false
    property string icon: ""
    property string label: ""
    property real value: 0
    property bool muted: false
    property bool showBar: true

    readonly property var sink: AudioState.sink
    readonly property var source: AudioState.source

    readonly property var player: {
        const list = Mpris.players.values;
        for (let i = 0; i < list.length; i++)
            if (list[i].isPlaying)
                return list[i];
        return list.length > 0 ? list[0] : null;
    }

    property real volumeStep: 5
    property var targetScreen: null
    property string titleBefore: ""
    property string pendingIcon: ""
    property int pollTicks: 0

    function showTrack(icon) {
        const p = root.trackPlayer;
        if (!p)
            return;
        const artist = p.trackArtist ? p.trackArtist + " – " : "";
        show(icon, artist + (p.trackTitle || "Unknown track"), 0, false, false);
    }

    // Remember the player we controlled and what it was playing before the skip
    function awaitTrack(p, icon) {
        trackPlayer = p;
        titleBefore = p.trackTitle || "";
        pendingIcon = icon;
        pollTicks = 0;
        trackShowTimer.stop();
        trackPoll.restart();
    }

    // Check the title every 100 ms for up to 3 s
    //
    Timer {
        id: trackPoll
        interval: 100
        repeat: true
        onTriggered: {
            root.pollTicks++;
            const p = root.trackPlayer;
            if (!p || root.pollTicks > 40) {          // 4 s
                stop();
                hideTimer.restart();
                // give up and hide normally
                return;
            }
            if (p.trackTitle && p.trackTitle !== root.titleBefore) {
                stop();
                trackShowTimer.restart();
            }
        }
    }
    Timer {
        id: trackShowTimer
        interval: 150
        onTriggered: root.showTrack(root.pendingIcon)
    }

    // Stop waiting if the title never changes (single track, end of queue)
    Timer {
        id: trackTimer
        interval: 2500
        onTriggered: root.awaitingTrack = false
    }

    Connections {
        target: root.player
        ignoreUnknownSignals: true
        function onTrackTitleChanged() {
            if (root.awaitingTrack)
                trackShowTimer.restart();
        }
    }

    function focusedScreen() {
        const mon = Hyprland.focusedMonitor;
        if (!mon)
            return null;
        for (let i = 0; i < Quickshell.screens.length; i++)
            if (Quickshell.screens[i].name === mon.name)
                return Quickshell.screens[i];
        return null;
    }
    property double lastShowAt: 0

    function show(icon, label, value, showBar, muted) {
        const now = Date.now();

        // Same content again within 250 ms: the reactive PipeWire update after an IPC call
        if (root.shown && icon === root.icon && label === root.label && value === root.value && muted === root.muted && now - root.lastShowAt < 250)
            return;
        root.lastShowAt = now;

        console.log("osd show:", label, "| was shown:", root.shown);
        if (!root.shown)
            root.targetScreen = root.focusedScreen();
        root.icon = icon;
        root.label = label;
        root.value = value;
        root.showBar = showBar;
        root.muted = muted;
        root.shown = true;
        hideTimer.restart();
    }

    function showVolumeValue(v, m) {
        show(AudioState.outputIcon(v, m), m ? "Muted" : Math.round(v * 100) + "%", v, true, m);
    }

    function showMicValue(v, m) {
        show(AudioState.micIcon(m), m ? "Mic muted" : Math.round(v * 100) + "%", v, true, m);
    }

    function showVolume() {
        if (!ready || !sink || !sink.audio)
            return;
        showVolumeValue(sink.audio.volume, sink.audio.muted);
    }

    function showMic() {
        if (!ready || !source || !source.audio)
            return;
        showMicValue(source.audio.volume, source.audio.muted);
    }

    // Applies a step and returns the new state, so the OSD can show it immediately
    function adjust(audio, action, maxPct) {
        let v = audio.volume;
        let m = audio.muted;
        if (action === "mute") {
            m = !m;
        } else {
            const lim = maxPct > 0 ? maxPct / 100 : 1.0;
            v = Math.max(0, Math.min(v + (action === "down" ? -1 : 1) * volumeStep / 100, lim));
        }
        audio.volume = v;
        audio.muted = m;
        return {
            v: v,
            m: m
        };
    }

    function media(action) {
        const p = root.player;
        if (!p) {
            show("\uf001", "No player", 0, false, true);
            return;
        }
        const title = p.trackTitle ? " · " + p.trackTitle : "";
        if (action === "playpause") {
            const willPlay = !p.isPlaying;
            p.togglePlaying();
            show(willPlay ? "\uf04b" : "\uf04c", (willPlay ? "Playing" : "Paused") + title, 0, false, false);
        } else if (action === "next") {
            root.awaitTrack(p, "\uf051");
            p.next();
            show("\uf051", "Next track", 0, false, false);
            hideTimer.stop();
        } else if (action === "previous") {
            root.awaitTrack(p, "\uf048");
            p.previous();
            show("\uf048", "Previous track", 0, false, false);
            hideTimer.stop();
        } else if (action === "stop") {
            p.stop();
            show("\uf04d", "Stopped", 0, false, false);
        }
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }
    PwObjectTracker {
        objects: root.source ? [root.source] : []
    }

    Timer {
        interval: 1500
        running: true
        onTriggered: root.ready = true
    }

    Timer {
        id: hideTimer
        interval: root.hideDelay
        onTriggered: root.shown = false
    }

    Connections {
        target: root.sink ? root.sink.audio : null
        ignoreUnknownSignals: true
        function onVolumeChanged() {
            root.showVolume();
        }
        function onMutedChanged() {
            root.showVolume();
        }
    }

    Connections {
        target: root.source ? root.source.audio : null
        ignoreUnknownSignals: true
        function onVolumeChanged() {
            root.showMic();
        }
        function onMutedChanged() {
            root.showMic();
        }
    }

    Process {
        id: brightProc
        stdout: StdioCollector {
            onStreamFinished: {
                // brightnessctl -m: name,class,current,percent%,max
                const f = text.trim().split("\n").pop().split(",");
                const pct = parseInt(f[3]);
                if (!isNaN(pct))
                    root.show("\uf185", pct + "%", pct / 100, true, false);
            }
        }
    }

    Process {
        id: capsProc
        command: ["sh", "-c", "sleep 0.05; cat /sys/class/leds/*::capslock/brightness | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const on = text.trim() === "1";
                root.show(on ? "\uf023" : "\uf09c", on ? "Caps Lock on" : "Caps Lock off", 0, false, false);
            }
        }
    }

    IpcHandler {
        target: "osd"

        function volume(action: string, max: int): void {
            if (!root.sink || !root.sink.audio)
                return;
            const r = root.adjust(root.sink.audio, action, max);
            root.showVolumeValue(r.v, r.m);
        }

        function mic(action: string): void {
            if (!root.source || !root.source.audio)
                return;
            const r = root.adjust(root.source.audio, action, 100);
            root.showMicValue(r.v, r.m);
        }

        function media(action: string): void {
            root.media(action);
        }

        function brightness(action: string): void {
            const arg = action === "down" ? root.step + "%-" : root.step + "%+";
            brightProc.command = ["brightnessctl", "-m", "set", arg];
            brightProc.running = true;
        }

        function capsLock(): void {
            if (!capsProc.running)
                capsProc.running = true;
        }
    }
    PanelWindow {
        id: win
        screen: root.targetScreen

        visible: root.shown || card.opacity > 0.01
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}                          // click-through

        anchors {
            bottom: true
        }
        margins {
            bottom: root.bottomOffset
        }

        implicitWidth: card.implicitWidth
        implicitHeight: card.implicitHeight

        WlrLayershell.namespace: "qs-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        Rectangle {
            id: card
            anchors.fill: parent
            implicitWidth: row.implicitWidth + 36
            implicitHeight: 56
            radius: 18
            opacity: root.shown ? 1 : 0
            color: Qt.alpha(Colors.shell.background, 0.95)
            border.width: 1
            border.color: Colors.shell.border

            Behavior on opacity {
                NumberAnimation {
                    duration: 180
                }
            }

            RowLayout {
                id: row
                anchors.centerIn: parent
                spacing: 14

                Text {
                    text: root.icon
                    color: Colors.shell.text
                    font.family: Options.fontFamily
                    font.pixelSize: 22
                    Layout.preferredWidth: 26
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle {
                    visible: root.showBar
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 8
                    radius: 4
                    color: Qt.alpha(Colors.shell.text, 0.15)

                    Rectangle {
                        width: parent.width * Math.max(0, Math.min(root.value, 1))
                        height: parent.height
                        radius: parent.radius
                        color: Colors.md3.primary
                        Behavior on width {
                            NumberAnimation {
                                duration: 120
                            }
                        }
                    }
                }

                Text {
                    Layout.minimumWidth: root.showBar ? 52 : 0
                    horizontalAlignment: Text.AlignRight
                    text: root.label
                    color: Colors.shell.text
                    font.pixelSize: 16
                    font.weight: Font.DemiBold

                    Layout.maximumWidth: 320
                    elide: Text.ElideRight
                }
            }
        }
    }
}
