pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import qs.Services

Scope {
  id: root

  property bool open: false
  property int mode: 0
  property string query: ""
  property int maxRows: 8

  // from your rofi config
  property var terminal: ["ghostty", "-e"]
  property string fontFamily: Options.fontFamily
  property real fontPt: 12

  readonly property string home: Quickshell.env("HOME")

  // modi: drun,run,filebrowser,window  (labels = display-*; paste your own glyphs if you like)
  readonly property var modes: [
    {
      id: "drun",
      label: "\uf009  Apps"
    },
    {
      id: "run",
      label: "\uf120  Run"
    },
    {
      id: "filebrowser",
      label: "\uf07b  Location"
    },
    {
      id: "window",
      label: "\uf2d0  Window"
    }
  ]
  readonly property string modeId: modes[mode].id

  property string fbPath: home
  property var fbEntries: []
  property var runCommands: []
  property var history: ({})
  property var pickFor: null          // app waiting for a file (Ctrl+o)

  // ---------- history (disable-history: false) ----------
  FileView {
    id: histFile
    path: root.home + "/.local/state/quickshell/launcher-history.json"
    onLoaded: {
      try {
        root.history = JSON.parse(text() || "{}")
      } catch (e) {}
    }
  }
  Component.onCompleted: Quickshell.execDetached(["mkdir", "-p", root.home
                                                  + "/.local/state/quickshell"])

  function bump(key) {
    const h = Object.assign({}, history)
    h[key] = (h[key] || 0) + 1
    history = h
    histFile.setText(JSON.stringify(h))
  }

  // ---------- data sources ----------
  Process {
    id: runProc
    command: ["sh", "-c",
      "find $(echo \"$PATH\" | tr : ' ') -maxdepth 1 \\( -type f -o -type l \\) -executable -printf '%f\\n' 2>/dev/null | sort -u"]
    stdout: StdioCollector {
      onStreamFinished: root.runCommands = text.split("\n").filter(l => l !== "")
    }
  }

  Process {
    id: lsProc
    command: ["sh", "-c", "cd \"$1\" 2>/dev/null && ls -1ApL --group-directories-first", "sh",
      root.fbPath]
    stdout: StdioCollector {
      onStreamFinished: root.fbEntries = text.split("\n").filter(l => l !== "").map(l => l.endsWith(
                                                                                           "/") ? {
                                                                                                    name: l.slice(
                                                                                                            0, -1),
                                                                                                    dir: true
                                                                                                  } : {
        name: l,
        dir: false
      })
    }
  }

  function reloadDir() {
    lsProc.running = false
    lsProc.running = true
  }

  function prepareMode() {
    if (modeId === "filebrowser")
      reloadDir()
    else if (modeId === "run" && runCommands.length === 0)
      runProc.running = true
    list.currentIndex = 0
  }

  onModeChanged: prepareMode()
  onQueryChanged: list.currentIndex = 0

  // ---------- mode handling ----------
  function openWith(id) {
    const i = modes.findIndex(m => m.id === id)
    pickFor = null
    query = ""
    fbPath = home
    mode = i >= 0 ? i : 0
    prepareMode()
    open = true
  }

  function cycleMode(d) {
    pickFor = null
    mode = (mode + d + modes.length) % modes.length
  }

  function startPick(item) {
    if (!item || (item.kind !== "drun" && item.kind !== "run"))
      return
    pickFor = item
    fbPath = home
    query = ""
    mode = modes.findIndex(m => m.id === "filebrowser")
  }

  function toggle() {
    if (open)
      open = false
    else
      openWith("drun")
  }

  IpcHandler {
    target: "launcher"
    function toggle(): void {
      root.toggle()
    }
    function show(mode: string): void {
      root.openWith(mode)
    }
    function close(): void {
      root.open = false
    }
  }

  GlobalShortcut {
    name: "launcher"
    description: "Toggle app launcher"
    onPressed: root.toggle()
  }

  // ---------- items + search ----------
  function rawItems() {
    if (modeId === "drun") {
      return DesktopEntries.applications.values.filter(e => !e.noDisplay).map(e => ({
        key: "drun:" + e.id,
        name: e.name,
        sub: e.comment || e.genericName || "",
        icon: e.icon,
        glyph: "\uf2d0",
        kind: "drun",
        data: e
      }))
    }

      if (modeId === "run") {
      return runCommands.map(c => ({
      key: "run:" + c,
      name: c,
      sub: "",
      icon: "",
      glyph: "\uf120",
      kind: "run",
      data: c
    }))
    }

      if (modeId === "window")
      return ToplevelManager.toplevels.values.map(t => ({
      key: "win:" + t.appId + t.title,
      name: t.title || t.appId,
      sub: t.appId,
      icon: t.appId,
      glyph: "\uf2d0",
      kind: "window",
      data: t
    }))

      const showHidden = query.startsWith(".")
      const out = [
      {
      key: "fb:..",
      name: "..",
      sub: "",
      icon: "",
      glyph: "\uf07b",
      kind: "dotdot",
      data: null
    }
      ]
      for (const e of fbEntries)
      if (showHidden || !e.name.startsWith("."))
      out.push({
      key: "fb:" + e.name,
      name: e.name,
      sub: "",
      icon: "",
      glyph: e.dir ? "\uf07b" : "\uf15b",
      kind: e.dir ? "dir" : "file",
      data: e
    })
      return out
    }

      function score(it, q) {
      const name = it.name.toLowerCase()
      if (name === q)
      return 1000
      if (name.startsWith(q))
      return 800
      if (name.split(/[\s\-_.\/]+/).some(w => w.startsWith(q)))
      return 600
      if (name.includes(q))
      return 400
      if (it.sub.toLowerCase().includes(q))
      return 150
      if (it.kind === "drun") {
      const e = it.data
      const extra = ((e.keywords || []).join(" ") + " " + (e.categories || []).join(
      " ")).toLowerCase()
      if (extra.includes(q))
      return 200
    }
      let i = 0
      for (const c of name)
      if (i < q.length && c === q[i])
      i++
      return i === q.length ? 50 : 0
    }

      readonly property var results: {
      const q = query.trim().toLowerCase()
      const h = history
      const items = rawItems()
      const hist = it => h[it.key] || 0
      const sortable = modeId === "drun" || modeId === "run"

      if (q === "") {
      if (!sortable)
      return items.slice(0, 400)
      return items.slice().sort((a, b) => hist(b) - hist(a) || a.name.localeCompare(b.name)).slice(0,
      400)
    }
      return items.map((it, i) => ({
      it: it,
      i: i,
      s: score(it, q)
    })).filter(x => x.s > 0).map(x => ({
      it: x.it,
      i: x.i,
      s: x.s + Math.min(hist(x.it), 20) * 5
    })).sort((a, b) => b.s - a.s || (sortable ? a.it.name.localeCompare(b.it.name) : a.i
      - b.i)).slice(0, 400).map(x => x.it)
    }

      function resolveIcon(name) {
      if (!name)
      return ""
      if (name.startsWith("/"))
      return "file://" + name
      let p = Quickshell.iconPath(name, true)
      if (p !== "")
      return p
      p = Quickshell.iconPath(name.toLowerCase(), true)
      if (p !== "")
      return p
      const e = DesktopEntries.heuristicLookup(name)
      if (e && e.icon)
      return e.icon.startsWith("/") ? "file://" + e.icon : Quickshell.iconPath(e.icon, true)
      return ""
    }

      // ---------- actions ----------
      function stripCodes(argv) {
      return argv.filter(a => !/^%[a-zA-Z]$/.test(a))
    }
      function inTerminal(argv) {
      Quickshell.execDetached(terminal.concat(argv))
    }

      function launchWith(item, file, termRun) {
      if (item.kind === "drun") {
      const e = item.data
      const argv = stripCodes(e.command)
      if (file) {
      const full = argv.concat([file])
      if (e.runInTerminal)
      inTerminal(full)
      else
      Quickshell.execDetached(full)
    } else if (e.runInTerminal) {
      inTerminal(argv)
    } else {
      e.execute()
    }
    } else if (item.kind === "run") {
      const argv = file ? ["sh", "-c", item.data + " \"$0\"", file] : ["sh", "-c", item.data]
      if (termRun)
      inTerminal(argv)
      else
      Quickshell.execDetached(argv)
    }
    }

      function navigate(p) {
      fbPath = p
      query = ""
      reloadDir()
    }

      function activate(item, termRun) {
      if (!item)
      return
      if (item.kind === "drun" || item.kind === "run") {
      bump(item.key)
      open = false
      launchWith(item, null, termRun)
    } else if (item.kind === "window") {
      open = false
      item.data.activate()
    } else if (item.kind === "dotdot") {
      navigate(fbPath.replace(/\/[^\/]+\/?$/, "") || "/")
    } else if (item.kind === "dir") {
      navigate(fbPath === "/" ? "/" + item.name : fbPath + "/" + item.name)
    } else if (item.kind === "file") {
      const path = fbPath === "/" ? "/" + item.name : fbPath + "/" + item.name
      open = false
      if (pickFor)
      launchWith(pickFor, path, false)
      else
      Quickshell.execDetached(["xdg-open", path])
    }
    }

      // ---------- window ----------
      PanelWindow {
      id: win

      screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
      ?? Quickshell.screens[0]
      visible: root.open || card.opacity > 0.01
      color: Qt.rgba(0, 0, 0, root.open ? 0.35 : 0)
      anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
      exclusionMode: ExclusionMode.Ignore

      Behavior on color {
      ColorAnimation {
      duration: 150
    }
    }

      WlrLayershell.namespace: "quickshell:launcher"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      onVisibleChanged: if (visible && root.open)
      input.forceActiveFocus()

      MouseArea {
      anchors.fill: parent
      onClicked: root.open = false
    }

      Rectangle {
      id: card
      anchors.centerIn: parent               // location: 0 (center)
      width: 640
      height: col.implicitHeight + 24
      radius: 20
      opacity: root.open ? 1 : 0
      color: Qt.alpha(Colors.md3.surfaceContainerHigh, 0.96)
      border.width: 1
      border.color: Qt.alpha(Colors.md3.outlineVariant, 0.7)

      Behavior on opacity {
      NumberAnimation {
      duration: 150
    }
    }

      MouseArea {
      anchors.fill: parent
    }

      ColumnLayout {
      id: col
      anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: 12
    }
      spacing: 10

      // input bar: prompt + entry
      Rectangle {
      Layout.fillWidth: true
      implicitHeight: 48
      radius: 14
      color: Colors.md3.surfaceContainerHighest

      RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 16
      anchors.rightMargin: 16
      spacing: 10

      Text {
      text: root.pickFor ? "\uf07b  Open " + root.pickFor.name + " with" :
      root.modes[root.mode].label
      color: Colors.md3.primary
      font.family: root.fontFamily
      font.pointSize: root.fontPt
      font.weight: Font.DemiBold
    }

      TextInput {
      id: input
      Layout.fillWidth: true
      text: root.query
      color: Colors.md3.onSurface
      selectionColor: Colors.md3.primary
      selectedTextColor: Colors.md3.onPrimary
      font.family: root.fontFamily
      font.pointSize: root.fontPt
      clip: true
      focus: true

      onTextEdited: root.query = text

      // your kb-* overrides + rofi defaults for mode switching
      Keys.onPressed: ev => {
      const ctrl = (ev.modifiers & Qt.ControlModifier) !== 0
      const shift = (ev.modifiers & Qt.ShiftModifier) !== 0
      const k = ev.key
      const current = list.currentItem ? list.currentItem.modelData : null
      ev.accepted = true

      if (k === Qt.Key_Escape)
      root.open = false
      else if (k === Qt.Key_Down || (ctrl && k === Qt.Key_J))
      list.currentIndex = Math.min(list.currentIndex + 1, list.count - 1)
      else if (k === Qt.Key_Up || (ctrl && k === Qt.Key_K))
      list.currentIndex = Math.max(list.currentIndex - 1, 0)
      else if ((k === Qt.Key_Return || k === Qt.Key_Enter) && !ctrl)
      root.activate(current, shift)
      else if (ctrl && (k === Qt.Key_Z || k === Qt.Key_Y))
      root.activate(current, false)
      else if ((shift && k === Qt.Key_Right) || (ctrl && k === Qt.Key_Tab))
      root.cycleMode(1)
      else if ((shift && k === Qt.Key_Left) || (ctrl && k === Qt.Key_Backtab))
      root.cycleMode(-1)
      else if (ctrl && k === Qt.Key_B)
      cursorPosition = Math.max(0, cursorPosition - 1)
      else if (ctrl && k === Qt.Key_F)
      cursorPosition = Math.min(text.length, cursorPosition + 1)
      else if (ctrl && k === Qt.Key_O)
      root.startPick(current)
      else
      // rofi: Left/Right/Ctrl+h/Ctrl+l are row-left/right, which do nothing in a single column
      if ((!shift && (k === Qt.Key_Left || k === Qt.Key_Right)) || (ctrl && (k === Qt.Key_H || k
      === Qt.Key_L))) {} else
      ev.accepted = false
    }
    }
    }
    }

      // current folder (filebrowser)
      Text {
      Layout.fillWidth: true
      visible: root.modeId === "filebrowser"
      text: root.fbPath.replace(root.home, "~")
      color: Colors.md3.onSurfaceVariant
      font.family: root.fontFamily
      font.pointSize: root.fontPt - 2
      elide: Text.ElideMiddle
    }

      ListView {
      id: list
      Layout.fillWidth: true
      Layout.preferredHeight: root.maxRows * 56
      clip: true
      spacing: 4
      currentIndex: 0
      boundsBehavior: Flickable.StopAtBounds
      highlightMoveDuration: 0
      model: ScriptModel {
      values: root.results
    }

      onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

      delegate: Rectangle {
      id: item
      required property var modelData
      required property int index
      readonly property bool current: ListView.isCurrentItem
      readonly property string iconSrc: root.resolveIcon(modelData.icon)

      width: ListView.view.width
      height: 52
      radius: 12
      color: current ? Colors.md3.primaryContainer : "transparent"

      RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 12
      anchors.rightMargin: 12
      spacing: 12

      Item {
      Layout.preferredWidth: 32
      Layout.preferredHeight: 32

      Image {
      id: appIcon
      anchors.fill: parent
      visible: item.iconSrc !== "" && status !== Image.Error
      source: item.iconSrc
      sourceSize: Qt.size(64, 64)
      fillMode: Image.PreserveAspectFit
      asynchronous: true
    }
      Text {
      anchors.centerIn: parent
      visible: !appIcon.visible
      text: item.modelData.glyph
      color: item.current ? Colors.md3.onPrimaryContainer : Colors.md3.onSurfaceVariant
      font.family: root.fontFamily
      font.pixelSize: 20
    }
    }

      ColumnLayout {
      Layout.fillWidth: true
      spacing: 0

      Text {
      Layout.fillWidth: true
      text: item.modelData.name
      color: item.current ? Colors.md3.onPrimaryContainer : Colors.md3.onSurface
      font.family: root.fontFamily
      font.pointSize: root.fontPt
      elide: Text.ElideRight
    }
      Text {
      Layout.fillWidth: true
      visible: text !== ""
      text: item.modelData.sub
      color: item.current ? Qt.alpha(Colors.md3.onPrimaryContainer, 0.75) :
      Colors.md3.onSurfaceVariant

      font.family: root.fontFamily
      font.pointSize: root.fontPt - 3
      elide: Text.ElideRight
    }
    }
    }

      MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onPositionChanged: list.currentIndex = item.index
      onClicked: root.activate(item.modelData, false)
    }
    }

      Text {
      anchors.centerIn: parent
      visible: list.count === 0
      text: "No results"
      color: Colors.md3.onSurfaceVariant
      font.family: root.fontFamily
      font.pointSize: root.fontPt
    }
    }
    }
    }
    }
    }
