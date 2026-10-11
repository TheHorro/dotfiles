pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Overrides. Leave empty for auto-detection.
  property string gpuTempPath: ""      // e.g. "/sys/class/hwmon/hwmon2/temp1_input"
  property string diskPath: "/"

  property string gpuBusyPath: ""
  // override, e.g. "/sys/class/hwmon/hwmon2/device/gpu_busy_percent"
  property real gpuPercent: 0
  property real memPercent: 0
  property var topProcs: []                // [{ pid, cpu, mem, name }]
  property bool panelOpen: false
  property double panelLastClosed: 0

  readonly property string gpuBase: gpuTempPath !== "" ? gpuTempPath : detectedGpuPath

  property real cpuPercent: 0
  property real memUsedBytes: 0
  property real diskPercent: -1
  property real diskUsedBytes: -1
  property real diskTotalBytes: -1
  property real gpuTempC: -1
  property real cpuTempC: -1
  property string iface: ""
  property string ip: ""
  property real rxRate: 0
  property real txRate: 0

  readonly property string cpuText: Math.round(cpuPercent) + "%"
  readonly property string memText: formatSize(memUsedBytes)
  readonly property string diskText: diskPercent >= 0 ? Math.round(diskPercent) + "%" : "--%"
  readonly property string diskUsedText: diskUsedBytes >= 0 ? formatSize(diskUsedBytes) : "--"
  readonly property string diskTotalText: diskTotalBytes >= 0 ? formatSize(diskTotalBytes) : "--"

  readonly property string gpuTempText: gpuTempC >= 0 ? Math.round(gpuTempC) + "°C" : "--°C"
  readonly property string gpuText: Math.round(gpuPercent) + "%"
  readonly property string netName: iface !== "" ? iface : "offline"
  readonly property string netIp: ip
  readonly property string upText: formatRate(txRate)
  readonly property string downText: formatRate(rxRate)
  readonly property string cpuTempText: cpuTempC >= 0 ? Math.round(cpuTempC) + "°C" : "--°C"

  property string cpuTempPath: ""        // e.g. "/sys/class/hwmon/hwmon1/temp1_input"
  property string detectedCpuPath: ""

  property string detectedGpuPath: ""
  property bool nvidiaMode: false
  property int _tick: 0
  property real _cpuTotal: -1
  property real _cpuIdle: 0
  property real _rx: -1
  property real _tx: 0
  property real _lastNet: 0

  function formatSize(b) {
    const g = b / 1073741824
    return g >= 1000 ? (g / 1024).toFixed(1) + "T" : g.toFixed(1) + "G"
  }

  function formatRate(v) {
    if (v >= 1e6)
      return (v / 1e6).toFixed(1) + "MB/s"
    if (v >= 1e3)
      return (v / 1e3).toFixed(1) + "kB/s"
    return Math.round(v) + "B/s"
  }

  function parseCpu(t) {
    const n = t.split("\n")[0].trim().split(/\s+/).slice(1).map(Number)
    const idle = n[3] + (n[4] || 0)
    const total = n.slice(0, 8).reduce((a, b) => a + b, 0)
    if (_cpuTotal >= 0) {
      const dt = total - _cpuTotal
      const di = idle - _cpuIdle
      cpuPercent = dt > 0 ? 100 * (dt - di) / dt : 0
    }
    _cpuTotal = total
    _cpuIdle = idle
  }

  function parseMem(t) {
    const total = /MemTotal:\s+(\d+)/.exec(t)
    const avail = /MemAvailable:\s+(\d+)/.exec(t)
    if (total && avail) {
      const used = Number(total[1]) - Number(avail[1])
      memUsedBytes = used * 1024
      memPercent = 100 * used / Number(total[1])
    }
  }

  function parseNet(t) {
    if (iface === "")
      return
    for (const raw of t.split("\n")) {
      const line = raw.trim()
      if (!line.startsWith(iface + ":"))
        continue
      const f = line.slice(iface.length + 1).trim().split(/\s+/)
      const rx = Number(f[0]), tx = Number(f[8])
      const now = Date.now()
      if (_rx >= 0 && now > _lastNet) {
        const dt = (now - _lastNet) / 1000
        rxRate = Math.max(0, (rx - _rx) / dt)
        txRate = Math.max(0, (tx - _tx) / dt)
      }
      _rx = rx
      _tx = tx
      _lastNet = now
      return
    }
  }

  function parseRoute(t) {
    const dev = /dev\s+(\S+)/.exec(t)
    const src = /src\s+(\S+)/.exec(t)
    const newIface = dev ? dev[1] : ""
    if (newIface !== iface) {
      _rx = -1
      rxRate = 0
      txRate = 0
    }
    iface = newIface
    ip = src ? src[1] : ""
  }

  function parseDisk(t) {
    const lines = t.trim().split("\n")
    if (lines.length < 2)
      return
    const f = lines[1].trim().split(/\s+/)
    diskUsedBytes = Number(f[0])
    diskTotalBytes = Number(f[1])
    diskPercent = parseInt(f[2])
  }

  function parseGpuDetect(t) {
    const line = t.trim().split("\n")[0]
    detectedGpuPath = line.startsWith("/") ? line : ""
    nvidiaMode = line === "nvidia"
  }

  function parseTop(t) {
    const rows = []
    for (const line of t.trim().split("\n")) {
      const f = line.trim().split(/\s+/)
      if (f.length < 4)
        continue
      rows.push({
                  pid: f[0],
                  cpu: Number(f[1]),
                  mem: Number(f[2]),
                  name: f.slice(3).join(" ")
                })
    }
    topProcs = rows
  }

  function closePanel() {
    panelOpen = false
    panelLastClosed = Date.now()
  }

  // The focus grab closes the panel on press, the bar click arrives on release.
  function togglePanel() {
    if (panelOpen)
      closePanel()
    else if (Date.now() - panelLastClosed > 300)
      panelOpen = true
  }

  FileView {
    id: statFile
    path: "/proc/stat"
    onLoaded: root.parseCpu(text())
  }
  FileView {
    id: memFile
    path: "/proc/meminfo"
    onLoaded: root.parseMem(text())
  }
  FileView {
    id: netFile
    path: "/proc/net/dev"
    onLoaded: root.parseNet(text())
  }
  FileView {
    id: cpuTempFile
    path: root.cpuTempPath !== "" ? root.cpuTempPath : root.detectedCpuPath
    onLoaded: root.cpuTempC = Number(text()) / 1000
  }

  Process {
    id: cpuTempDetect
    running: root.cpuTempPath === ""
    command: ["sh", "-c",
      "for h in /sys/class/hwmon/hwmon*; do case \"$(cat $h/name 2>/dev/null)\" in k10temp|zenpower|coretemp|cpu_thermal) echo $h/temp1_input; exit;; esac; done"]
    stdout: StdioCollector {
      onStreamFinished: root.detectedCpuPath = text.trim()
    }
  }

  FileView {
    id: gpuFile
    path: root.gpuTempPath !== "" ? root.gpuTempPath : root.detectedGpuPath
    onLoaded: root.gpuTempC = Number(text()) / 1000
  }

  FileView {
    id: gpuBusyFile
    path: root.gpuBusyPath !== "" ? root.gpuBusyPath : (root.gpuBase !== "" && !root.nvidiaMode
                                                        ? root.gpuBase.replace("temp1_input",
                                                                               "device/gpu_busy_percent") :
                                                          "")
    onLoaded: root.gpuPercent = Number(text())
  }

  Process {
    id: gpuDetect
    running: root.gpuTempPath === ""
    command: ["sh", "-c",
      "for h in /sys/class/hwmon/hwmon*; do if [ \"$(cat $h/name 2>/dev/null)\" = amdgpu ]; then echo $h/temp1_input; exit; fi; done; command -v nvidia-smi >/dev/null && echo nvidia"]
    stdout: StdioCollector {
      onStreamFinished: root.parseGpuDetect(text)
    }
  }

  Process {
    id: nvidiaProc
    command: ["nvidia-smi", "--query-gpu=temperature.gpu,utilization.gpu",
      "--format=csv,noheader,nounits"]
    stdout: StdioCollector {
      onStreamFinished: {
        const p = text.trim().split("\n")[0].split(",")
        const t = Number(p[0]), u = Number(p[1])
        if (!isNaN(t))
          root.gpuTempC = t
        if (!isNaN(u))
          root.gpuPercent = u
      }
    }
  }
  Process {
    id: routeProc
    command: ["ip", "-4", "route", "get", "1.1.1.1"]
    stdout: StdioCollector {
      onStreamFinished: root.parseRoute(text)
    }
  }

  Process {
    id: diskProc
    command: ["df", "-B1", "--output=used,size,pcent", root.diskPath]
    stdout: StdioCollector {
      onStreamFinished: root.parseDisk(text)
    }
  }

  Process {
    id: topProc
    command: ["sh", "-c",
      "LC_ALL=C top -b -n 2 -d 0.5 -w 200 -o %CPU | awk -v n=$(nproc) '/^top -/{i++} i==2 && $1 ~ /^[0-9]+$/ {printf \"%s %.1f %.1f %s\\n\", $1, $9/n, $10, $12}' | head -n 5"]
    stdout: StdioCollector {
      onStreamFinished: root.parseTop(text)
    }
  }

  Timer {
    interval: 2000
    running: root.panelOpen
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!topProc.running)
                   topProc.running = true
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      statFile.reload()
      memFile.reload()
      netFile.reload()
      if (gpuFile.path !== "")
        gpuFile.reload()
      else if (root.nvidiaMode && root._tick % 3 === 0 && !nvidiaProc.running)
        nvidiaProc.running = true
      if (cpuTempFile.path !== "")
        cpuTempFile.reload()
      if (gpuBusyFile.path !== "")
        gpuBusyFile.reload()

      root._tick++
    }
  }

  Timer {
    interval: 10000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: {
      if (!routeProc.running)
        routeProc.running = true
      if (!diskProc.running)
        diskProc.running = true
    }
  }
}
