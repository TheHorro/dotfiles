pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.Mpris
import qs.Services

Scope {
  id: root

  property bool open: false
  property int tab: 0   // 0 = notifications, 1 = mixer
  property string subPanel: ""     // "", "wifi" or "bluetooth"

  IpcHandler {
    target: "controlCenter"
    function toggle(): void {
      root.toggle()
    }
    function open(): void {
      root.open = true
    }
    function close(): void {
      root.open = false
    }
  }

  property double lastClosed: 0

  onOpenChanged: {
    if (!open) {
      lastClosed = Date.now()
      subPanel = ""
    }
    Controls.networkWatch = open
    Notifs.centerOpen = open
    if (open) {
      Notifs.clearPopups()
      Controls.refresh()
    }
  }

  function toggle() {
    // ignore the click that just closed it via the focus grab
    if (!open && Date.now() - lastClosed < 200)
      return
    open = !open
  }

  Connections {
    target: Notifs
    function onToggleCenter() {
      root.toggle()
    }
  }

  GlobalShortcut {
    name: "controlCenter"
    description: "Toggle control center"
    onPressed: root.toggle()
  }

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property var source: Pipewire.defaultAudioSource

  // bind every node so its properties become valid
  PwObjectTracker {
    objects: Pipewire.nodes.values
  }

  readonly property var streams: Pipewire.nodes.values.filter(n => n.ready && n.audio && n.isStream
                                                                   && n.isSink
                                                                   && n.properties["media.class"]
                                                                   === "Stream/Output/Audio")

  PanelWindow {
    id: panel

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0]
    visible: root.open || card.opacity > 0.01
    color: "transparent"

    anchors {
      top: true
      right: true
      bottom: true
    }
    margins {
      top: 6
      right: 8
      bottom: 8
    }
    implicitWidth: 420
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell:controlcenter"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    HyprlandFocusGrab {
      windows: [panel]
      active: root.open
      onCleared: root.open = false
    }

    Rectangle {
      id: card
      width: parent.width
      height: parent.height
      x: root.open ? 0 : 40
      opacity: root.open ? 1 : 0
      radius: 20
      color: Colors.shell.background
      border.width: 1
      border.color: Colors.md3.outlineVariant
      focus: root.open
      Keys.onEscapePressed: root.open = false

      Behavior on x {
        NumberAnimation {
          duration: 180
          easing.type: Easing.OutCubic
        }
      }
      Behavior on opacity {
        NumberAnimation {
          duration: 150
        }
      }

      ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Text {
            Layout.fillWidth: true
            text: "Up " + Controls.uptime
            color: Colors.shell.textMuted
            font.pixelSize: 13
            elide: Text.ElideRight
          }
          IconButton {
            icon: ""
            onClicked: {
              root.open = false
              Quickshell.execDetached(["loginctl", "lock-session"])
            }
          }
          IconButton {
            icon: ""
            onClicked: Quickshell.reload(true)
          }
          IconButton {
            icon: ""
            onClicked: {
              root.open = false
              Quickshell.execDetached(["wlogout"])
            }
          }
        }

        // Quick toggles
        GridLayout {
          Layout.fillWidth: true
          columns: 3
          columnSpacing: 8
          rowSpacing: 8

          ToggleTile {
            readonly property bool eth: Controls.ethernet
            icon: eth ? String.fromCodePoint(0xF0200) : ""
            label: eth ? "Ethernet" : !Controls.wifi ? "Wi-Fi off" : (Controls.wifiSsid !== ""
                                                                      ? Controls.wifiSsid : "Wi-Fi")
            active: eth || Controls.wifi
            onClicked: if (!eth)
                         Controls.toggleWifi()
            onRightClicked: if (!eth)
                              root.subPanel = root.subPanel === "wifi" ? "" : "wifi"
          }

          ToggleTile {
            icon: ""
            label: !Controls.bluetooth ? "Bluetooth off" : Controls.btConnected.length === 0
                                         ? "Bluetooth" : Controls.btConnected.length === 1
                                           ? Controls.btConnected[0].name :
                                             Controls.btConnected.length + " devices"
            active: Controls.bluetooth
            onClicked: Controls.toggleBluetooth()
            onRightClicked: root.subPanel = root.subPanel === "bluetooth" ? "" : "bluetooth"
          }

          ToggleTile {
            icon: Notifs.dnd ? "" : ""
            label: "Do not disturb"
            onClicked: Notifs.dnd = !Notifs.dnd
            active: Notifs.dnd
          }
          ToggleTile {
            icon: ""
            label: "Night light"
            active: Controls.nightLight
            onClicked: Controls.toggleNightLight()
          }
          ToggleTile {
            icon: ""
            label: "Caffeine"
            active: Controls.caffeine
            onClicked: Controls.caffeine = !Controls.caffeine
          }
          ToggleTile {
            readonly property bool muted: root.source?.audio?.muted ?? false
            icon: muted ? "󰍭" : ""
            label: muted ? "Mic off" : "Mic on"
            active: muted
            onClicked: if (root.source?.audio)
                         root.source.audio.muted = !muted
          }
        }
        WifiPanel {
          visible: root.subPanel === "wifi" && !Controls.ethernet
        }

        BluetoothPanel {
          visible: root.subPanel === "bluetooth"
        }

        // Sliders
        SliderRow {
          readonly property bool muted: root.sink?.audio?.muted ?? false
          icon: muted ? "" : ""
          value: root.sink?.audio?.volume ?? 0
          dimmed: muted
          onMoved: v => {
            if (root.sink?.audio)
              root.sink.audio.volume = v
          }
          onIconClicked: if (root.sink?.audio)
                           root.sink.audio.muted = !muted
        }
        SliderRow {
          visible: Device.brightnessCrtl
          icon: ""
          value: Controls.brightness
          onMoved: v => Controls.setBrightness(v)
        }

        // Tabs
        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          Repeater {
            model: ["Notifications", "Mixer"]
            delegate: Rectangle {
              required property string modelData
              required property int index
              Layout.fillWidth: true
              implicitHeight: 32
              radius: 16
              color: root.tab === index ? Colors.shell.cardActive : "transparent"

              Text {
                anchors.centerIn: parent
                text: parent.modelData + (parent.index === 0 && Notifs.count > 0 ? "  "
                                                                                   + Notifs.count :
                                                                                   "")
                color: root.tab === parent.index ? Colors.shell.text : Colors.shell.textMuted
                font.pixelSize: 13
                font.weight: Font.Medium
              }
              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.tab = parent.index
              }
            }
          }
        }

        // Notifications tab
        ColumnLayout {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: root.tab === 0
          spacing: 8

          ListView {
            id: notifList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: Notifs.list
            delegate: NotificationCard {}

            add: Transition {
              NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 150
              }
            }
            remove: Transition {
              NumberAnimation {
                property: "opacity"
                to: 0
                duration: 120
              }
            }
            displaced: Transition {
              NumberAnimation {
                properties: "y"
                duration: 150
              }
            }

            Text {
              anchors.centerIn: parent
              visible: Notifs.count === 0
              text: "No notifications"
              color: Colors.shell.textDisabled
              font.pixelSize: 14
            }
          }

          Rectangle {
            Layout.alignment: Qt.AlignRight
            visible: Notifs.count > 0
            implicitWidth: clearLbl.implicitWidth + 24
            implicitHeight: 30
            radius: 15
            color: clearMa.containsMouse ? Colors.shell.cardActive : Colors.shell.card

            Text {
              id: clearLbl
              anchors.centerIn: parent
              text: "Clear all"
              color: Colors.shell.text
              font.pixelSize: 12
            }
            MouseArea {
              id: clearMa
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: Notifs.clearAll()
            }
          }
        }

        // Mixer tab
        ListView {
          Layout.fillWidth: true
          Layout.fillHeight: true
          visible: root.tab === 1
          clip: true
          spacing: 10
          model: root.streams

          delegate: RowLayout {
            id: stream
            required property var modelData

            width: ListView.view.width
            spacing: 10

            readonly property var props: modelData.properties
            readonly property string appName: props["application.name"] || modelData.nickname
                                              || modelData.name
            readonly property string mediaTitle: {
              const t = props["media.name"] || ""
              return (t === "" || t === "Playback" || t === "AudioStream" || t === appName) ? "" : t
            }

            // try the icon name, binary name and app name, then look it up via the .desktop entry
            readonly property string iconSource: {
              const names = [props["application.icon-name"], props["application.process.binary"],
                             appName, appName.toLowerCase()].filter(n => n)
              for (const name of names) {
                const direct = Quickshell.iconPath(name, true)
                if (direct !== "")
                  return direct
                const entry = DesktopEntries.heuristicLookup(name)
                if (entry && entry.icon) {
                  const viaEntry = Quickshell.iconPath(entry.icon, true)
                  if (viaEntry !== "")
                    return viaEntry
                }
              }
              return ""
            }

            // optional: MPRIS cover art (YouTube thumbnail, Tidal album art)
            readonly property var player: Mpris.players.values.find(p => p.identity.toLowerCase(
                                                                           ).includes(
                                                                           appName.toLowerCase())
                                                                         || (p.desktopEntry
                                                                             || "").toLowerCase(
                                                                           ).includes(
                                                                           appName.toLowerCase()))
            readonly property string artUrl: player ? player.trackArtUrl : ""

            Item {
              Layout.preferredWidth: 40
              Layout.preferredHeight: 40
              Layout.alignment: Qt.AlignVCenter

              Image {
                id: appIcon
                anchors.fill: parent
                visible: stream.artUrl === "" && source !== "" && status !== Image.Error
                source: stream.iconSource
                sourceSize: Qt.size(80, 80)
                fillMode: Image.PreserveAspectFit
                asynchronous: true
              }

              Image {
                id: art
                anchors.fill: parent
                visible: stream.artUrl !== "" && status === Image.Ready
                source: stream.artUrl
                sourceSize: Qt.size(80, 80)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
              }

              // fallback glyph
              Text {
                anchors.centerIn: parent
                visible: !appIcon.visible && !art.visible
                text: ""
                color: Colors.shell.textMuted
                font.family: Options.fontFamily
                font.pixelSize: 22
              }
            }

            ColumnLayout {
              Layout.fillWidth: true
              spacing: 2

              Text {
                Layout.fillWidth: true
                text: stream.appName + (stream.mediaTitle !== "" ? "  ·  " + stream.mediaTitle : "")
                color: Colors.shell.textMuted
                font.pixelSize: 12
                elide: Text.ElideRight
              }

              SliderRow {
                icon: stream.modelData.audio.muted ? "" : ""
                value: stream.modelData.audio.volume
                dimmed: stream.modelData.audio.muted
                onMoved: v => stream.modelData.audio.volume = v
                onIconClicked: stream.modelData.audio.muted = !stream.modelData.audio.muted
              }
            }
          }

          Text {
            anchors.centerIn: parent
            visible: root.streams.length === 0
            text: "No apps playing audio"
            color: Colors.shell.textDisabled
            font.pixelSize: 14
          }
        }
      }
    }
  }
}
