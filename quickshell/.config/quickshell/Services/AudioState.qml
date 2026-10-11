pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
  id: root

  property var ignoredSinks: ["Easy Effects Sink"]
  property real maxVolume: 1.0
  property real micMaxVolume: 1.0
  property real step: 0.05

  // Default sink, unless it is ignored: then the first real output
  readonly property var sink: {
    const d = Pipewire.defaultAudioSink
    if (d && root.ignoredSinks.indexOf(d.description) === -1)
      return d
    const nodes = Pipewire.nodes.values
    for (let i = 0; i < nodes.length; i++) {
      const n = nodes[i]
      if (n.isSink && !n.isStream && root.ignoredSinks.indexOf(n.description) === -1)
        return n
    }
    return d
  }
  readonly property var source: Pipewire.defaultAudioSource

  PwObjectTracker {
    objects: [root.sink, root.source].filter(o => o)
  }

  readonly property real volume: sink && sink.audio ? sink.audio.volume : 0
  readonly property bool muted: Boolean(sink && sink.audio && sink.audio.muted)
  readonly property real micVolume: source && source.audio ? source.audio.volume : 0
  readonly property bool micMuted: Boolean(source && source.audio && source.audio.muted)

  readonly property string sinkDescription: sink ? (sink.description || sink.name) : "No output"
  readonly property string sourceDescription: source ? (source.description || source.name) :
                                                       "No input"

  readonly property bool bluetooth: Boolean(sink && sink.name && sink.name.indexOf("bluez") === 0)
  readonly property string formFactor: {
    if (!sink || !sink.properties)
      return ""
    const p = sink.properties
    return p["device.form-factor"] || p["device.form_factor"] || ""
  }

  readonly property string mutedIcon: "󰖁"
  readonly property string btIcon: "󰂰"
  readonly property string micIconOn: ""
  readonly property string micIconOff: "󰍭"

  // off, low, mid, high (waybar "default" icons)
  readonly property var levelIcons: ["", "", "", ""]
  readonly property var formIcons: ({
                                      "headphone": "",
                                      "hands-free": "",
                                      "headset": "",
                                      "phone": "",
                                      "portable": "",
                                      "car": ""
                                    })

  function outputIcon(v, m) {
    if (m)
      return root.mutedIcon
    const ff = root.formIcons[root.formFactor]
    if (ff)
      return ff
    return root.levelIcons[Math.min(3, Math.floor(v * 100 / 25))]
  }

  function micIcon(m) {
    return m ? root.micIconOff : root.micIconOn
  }

  readonly property string outputIconText: outputIcon(volume, muted) + (bluetooth && !muted ? " "
                                                                                              + btIcon :
                                                                                              "")

  function clamp(x, lo, hi) {
    return Math.max(lo, Math.min(x, hi))
  }

  function stepSink(dir) {
    if (!sink || !sink.audio)
      return
    sink.audio.volume = clamp(sink.audio.volume + (dir === "down" ? -1 : 1) * step, 0, maxVolume)
  }

  function stepSource(dir) {
    if (!source || !source.audio)
      return
    source.audio.volume = clamp(source.audio.volume + (dir === "down" ? -1 : 1) * step, 0,
                                micMaxVolume)
  }

  function toggleSinkMute() {
    if (sink && sink.audio)
      sink.audio.muted = !sink.audio.muted
  }

  function toggleSourceMute() {
    if (source && source.audio)
      source.audio.muted = !source.audio.muted
  }
}
