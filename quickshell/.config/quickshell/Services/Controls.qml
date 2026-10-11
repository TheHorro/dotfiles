pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

Singleton {
  id: root

  property bool wifi: false
  property bool nightLight: false
  property bool caffeine: false
  property real brightness: 0
  property string uptime: ""

  readonly property bool bluetooth: Bluetooth.defaultAdapter ? Bluetooth.defaultAdapter.enabled :
                                                               false
  readonly property var btConnected: Bluetooth.defaultAdapter
                                     ? Bluetooth.defaultAdapter.devices.values.filter(d
                                                                                      => d.connected) :
                                       []

  property bool ethernet: false
  property string wifiDevice: ""
  property string wifiSsid: ""
  property var wifiNetworks: []       // [{ssid, signal, secure, inUse}]
  property var savedConnections: []
  property string netStatus: ""
  property bool connecting: false
  property bool networkWatch: false   // set by the control center while open

  PersistentProperties {
    id: persist
    reloadableId: "controls"
    property bool caffeine: false
  }

  function refresh() {
    wifiProc.running = true
    nightProc.running = true
    brightProc.running = true
    uptimeProc.running = true
    netProc.running = true
    listProc.running = true
    savedProc.running = true
  }

  function splitTerse(line) {
    const out = []
    let cur = ""
    for (let i = 0; i < line.length; i++) {
      const c = line[i]
      if (c === "\\" && i + 1 < line.length) {
        cur += line[i + 1]
        i++
      } else if (c === ":") {
        out.push(cur)
        cur = ""
      } else
        cur += c
    }
    out.push(cur)
    return out
  }

  function scan() {
    rescanProc.running = true
  }

  function connectWifi(ssid, password) {
    netStatus = "Connecting to " + ssid + "…"
    connecting = true
    let args
    if (!password && savedConnections.indexOf(ssid) !== -1)
      args = ["connection", "up", "id", ssid]
    else if (password)
      args = ["device", "wifi", "connect", ssid, "password", password]
    else
      args = ["device", "wifi", "connect", ssid]
    // prints "<exit code>:<output>" so the result can be read from stdout
    connectProc.command = ["sh", "-c", 'out=$(nmcli "$@" 2>&1); echo "$?:$out"', "sh", ...args]
    connectProc.running = true
  }

  function disconnectWifi() {
    if (wifiDevice === "")
      return
    Quickshell.execDetached(["nmcli", "device", "disconnect", wifiDevice])
    afterTimer.restart()
  }

  Timer {
    id: netTimer
    interval: 5000
    running: root.networkWatch
    repeat: true
    onTriggered: {
      netProc.running = true
      listProc.running = true
    }
  }

  Timer {
    id: afterTimer
    interval: 900
    onTriggered: {
      netProc.running = true
      listProc.running = true
    }
  }

  Process {
    id: netProc
    command: ["nmcli", "-t", "-f", "TYPE,STATE,DEVICE", "device", "status"]
    stdout: StdioCollector {
      onStreamFinished: {
        let eth = false
        let dev = ""
        for (const line of text.trim().split("\n")) {
          const f = root.splitTerse(line)
          if (f[0] === "ethernet" && f[1] === "connected")
            eth = true
          if (f[0] === "wifi" && dev === "")
            dev = f[2]
        }
        root.ethernet = eth
        root.wifiDevice = dev
      }
    }
  }

  Process {
    id: listProc
    command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "device", "wifi", "list",
      "--rescan", "no"]
    stdout: StdioCollector {
      onStreamFinished: {
        const best = {}
        for (const line of text.trim().split("\n")) {
          if (line === "")
            continue
          const f = root.splitTerse(line)
          const ssid = f[1]
          if (!ssid)
            continue
          const n = {
            ssid: ssid,
            signal: parseInt(f[2]) || 0,
            secure: (f[3] || "") !== "",
            inUse: f[0] === "*"
          }
          const old = best[ssid]
          if (!old || n.inUse || (!old.inUse && n.signal > old.signal))
            best[ssid] = n
        }
        const list = Object.values(best)
        list.sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal))
        root.wifiNetworks = list
        const active = list.find(n => n.inUse)
        root.wifiSsid = active ? active.ssid : ""
      }
    }
  }

  Process {
    id: savedProc
    command: ["nmcli", "-t", "-f", "NAME,TYPE", "connection", "show"]
    stdout: StdioCollector {
      onStreamFinished: {
        const names = []
        for (const line of text.trim().split("\n")) {
          const f = root.splitTerse(line)
          if (f[1] === "802-11-wireless")
            names.push(f[0])
        }
        root.savedConnections = names
      }
    }
  }

  Process {
    id: rescanProc
    command: ["nmcli", "device", "wifi", "rescan"]
    onExited: listProc.running = true
  }

  Process {
    id: connectProc
    stdout: StdioCollector {
      onStreamFinished: {
        const i = text.indexOf(":")
        const code = parseInt(text.substring(0, i))
        const msg = text.substring(i + 1).trim().split("\n")[0]
        root.connecting = false
        root.netStatus = code === 0 ? "" : (msg || "Connection failed")
        netProc.running = true
        listProc.running = true
        savedProc.running = true
      }
    }
  }

  function toggleWifi() {
    Quickshell.execDetached(["nmcli", "radio", "wifi", wifi ? "off" : "on"])
    wifi = !wifi
  }

  function toggleBluetooth() {
    if (Bluetooth.defaultAdapter)
      Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
  }

  function toggleNightLight() {
    Quickshell.execDetached(["sh", "-c", nightLight ? "pkill -x hyprsunset" : "hyprsunset -t 4000"])
    nightLight = !nightLight
  }

  function setBrightness(v) {
    brightness = Math.max(0.01, Math.min(1, v))
    brightTimer.restart()
  }

  Timer {
    id: brightTimer
    interval: 60
    onTriggered: Quickshell.execDetached(["brightnessctl", "set", Math.round(root.brightness * 100)
                                          + "%"])
  }

  Process {
    id: caffeineProc
    running: root.caffeine
    command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=Caffeine", "sleep",
      "infinity"]
  }

  Process {
    id: wifiProc
    command: ["nmcli", "radio", "wifi"]
    stdout: StdioCollector {
      onStreamFinished: root.wifi = text.trim() === "enabled"
    }
  }

  Process {
    id: nightProc
    command: ["pgrep", "-x", "hyprsunset"]
    onExited: code => root.nightLight = (code === 0)
  }

  Process {
    id: brightProc
    command: ["brightnessctl", "-m"]
    stdout: StdioCollector {
      onStreamFinished: {
        const pct = parseInt(text.split(",")[3])
        if (!isNaN(pct))
          root.brightness = pct / 100
      }
    }
  }

  Process {
    id: uptimeProc
    command: ["uptime", "-p"]
    stdout: StdioCollector {
      onStreamFinished: root.uptime = text.trim().replace(/^up /, "")
    }
  }

  Component.onCompleted: refresh()
}
