pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Services

Scope {
  id: root

  property bool open: false
  property int current: -1                 // keyboard focus index
  property int edgeMargin: 200             // like wlogout -m
  property int buttonMargin: 10            // CSS margin: 10px
  property int buttonRadius: 36            // CSS border-radius
  property real iconScale: 0.2             // CSS background-size: 20%
  readonly property string iconDir: "file://" + Quickshell.env("HOME") + "/.config/wlogout/icons/"

  // Rename these to your Colors singleton (primary / surface / surface_bright)
  readonly property color cText: Colors.md3.primary
  readonly property color cSurface: Colors.md3.surface
  readonly property color cSurfaceBright: Colors.md3.surfaceBright
  readonly property color cBackdrop: Qt.alpha(Colors.md3.surface, 0.8)   // @surface-alpha

  readonly property var actions: [
    {
      id: "lock",
      label: "Lock",
      key: Qt.Key_L,
      icon: "lock",
      cmd: ["loginctl", "lock-session"]
    },
    {
      id: "logout",
      label: "Logout",
      key: Qt.Key_E,
      icon: "logout",
      cmd: ["hyprctl", "dispatch", "exit"]
    },
    {
      id: "sleep",
      label: "Sleep",
      key: Qt.Key_U,
      icon: "hibernate",
      cmd: ["systemctl", "suspend"]
    },
    {
      id: "reboot",
      label: "Reboot",
      key: Qt.Key_R,
      icon: "restart",
      cmd: ["systemctl", "reboot"]
    },
    {
      id: "shutdown",
      label: "Shutdown",
      key: Qt.Key_S,
      icon: "power",
      cmd: ["systemctl", "poweroff"]
    }
  ]

  function toggle() {
    open = !open
  }
  function run(cmd) {
    open = false
    // short delay so the overlay is gone before locking/suspending
    Quickshell.execDetached(["sh", "-c", "sleep 0.15; exec \"$@\"", "sh", ...cmd])
  }
  property string targetScreen: ""

  onOpenChanged: {
    current = -1
    if (open)
      targetScreen = Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : ""
  }

  IpcHandler {
    target: "sessionMenu"
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

  component SessionButton: Rectangle {
    id: btn
    required property string iconName
    property bool focused: false
    required property string label
    signal activated

    readonly property bool hovered: ma.containsMouse

    radius: root.buttonRadius
    color: hovered ? root.cSurfaceBright : focused ? root.cSurface : "transparent"
    scale: hovered || focused ? 1.03 : 1.0

    Behavior on color {
      ColorAnimation {
        duration: 300
      }
    }
    Behavior on scale {
      NumberAnimation {
        duration: 300
        easing.type: Easing.OutBack
        easing.overshoot: 1.7
      }
    }

    // box-shadow: 0 0 10px 3px rgba(0,0,0,.4) on hover/focus
    layer.enabled: true
    layer.effect: MultiEffect {
      shadowEnabled: btn.hovered || btn.focused
      shadowColor: Qt.rgba(0, 0, 0, 0.4)
      shadowBlur: 0.6
      shadowScale: 1.0
    }

    Column {
      anchors.centerIn: parent
      spacing: 18

      Image {
        anchors.horizontalCenter: parent.horizontalCenter
        width: btn.width * root.iconScale
        height: width
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        sourceSize: Qt.size(256, 256)
        source: root.iconDir + btn.iconName + (btn.hovered ? "-hover" : "") + ".png"
      }

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: btn.label
        color: root.cText
        font.family: Options.fontFamily
        font.pixelSize: 21                       // about 16pt
        opacity: btn.hovered || btn.focused ? 1.0 : 0.7
        Behavior on opacity {
          NumberAnimation {
            duration: 300
          }
        }
      }
    }
    MouseArea {
      id: ma
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: btn.activated()
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win
      required property var modelData
      screen: modelData
      readonly property bool isTarget: root.targetScreen === "" || modelData.name
                                       === root.targetScreen

      visible: root.open
      // visible: root.open && (root.targetScreen === "" || modelData.name === root.targetScreen)

      color: root.cBackdrop
      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }
      exclusionMode: ExclusionMode.Ignore

      WlrLayershell.namespace: "quickshell:sessionmenu"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: root.open && win.isTarget ? WlrKeyboardFocus.Exclusive :
                                                               WlrKeyboardFocus.None

      // click on backdrop closes
      MouseArea {
        anchors.fill: parent
        onClicked: root.open = false
      }

      Item {
        anchors.fill: parent
        visible: win.isTarget
        focus: win.isTarget

        Keys.onPressed: ev => {
          if (ev.key === Qt.Key_Escape) {
            root.open = false
            return
          }
          if (ev.key === Qt.Key_Left) {
            root.current = Math.max(0, (root.current < 0 ? 0 : root.current - 1))
            return
          }
          if (ev.key === Qt.Key_Right) {
            root.current = Math.min(root.actions.length - 1, root.current + 1)
            return
          }
          if ((ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) && root.current >= 0) {
            root.run(root.actions[root.current].cmd)
            return
          }
          for (const a of root.actions)
            if (ev.key === a.key) {
              root.run(a.cmd)
              return
            }
        }

        RowLayout {
          anchors.fill: parent
          anchors.margins: root.edgeMargin
          spacing: 0

          Repeater {
            model: root.actions

            SessionButton {
              required property var modelData
              required property int index

              Layout.fillWidth: true
              Layout.fillHeight: true
              Layout.margins: root.buttonMargin

              iconName: modelData.icon
              label: modelData.label
              focused: root.current === index
              onActivated: root.run(modelData.cmd)
            }
          }
        }
      }
    }
  }
}
