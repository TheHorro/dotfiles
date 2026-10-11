pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Services
import qs.Components

Scope {
  id: root

  property int topOffset: 36      // bar height + gap

  PanelWindow {
    id: win

    visible: SystemStats.panelOpen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true                   // only top: horizontally centred on the screen
    }
    margins {
      top: root.topOffset
    }

    implicitWidth: 360
    implicitHeight: panel.implicitHeight

    WlrLayershell.namespace: "qs-stats-panel"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    HyprlandFocusGrab {
      windows: [win]
      active: win.visible
      onCleared: SystemStats.closePanel()
    }

    Shortcut {
      sequence: "Escape"
      onActivated: SystemStats.closePanel()
    }

    Rectangle {
      id: panel
      anchors.fill: parent
      implicitHeight: col.implicitHeight + 28
      radius: 16
      color: Qt.alpha(Colors.md3.background, 0.96)
      border.width: 1
      border.color: Colors.md3.outlineVariant

      ColumnLayout {
        id: col
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: 22

          CircleGauge {
            label: "CPU"
            value: SystemStats.cpuPercent
            color: Colors.shell.accent
          }
          CircleGauge {
            label: "GPU"
            value: SystemStats.gpuPercent
            color: Colors.shell.success
          }
          CircleGauge {
            label: "RAM"
            value: SystemStats.memPercent
            color: Colors.shell.warning
          }
        }

        Rectangle {
          Layout.fillWidth: true
          height: 1
          color: Colors.md3.outlineVariant
        }

        RowLayout {
          Layout.fillWidth: true

          Text {
            Layout.fillWidth: true
            text: "Top processes"
            color: Colors.shell.text
            font.pixelSize: Options.textSize + 1
            font.weight: Font.DemiBold
          }
          Text {
            Layout.preferredWidth: 56
            horizontalAlignment: Text.AlignRight
            text: "CPU"
            color: Colors.shell.accent
            font.pixelSize: Options.textSize
          }
          Text {
            Layout.preferredWidth: 56
            horizontalAlignment: Text.AlignRight
            text: "RAM"
            color: Colors.shell.warning
            font.pixelSize: Options.textSize
          }
        }

        Text {
          visible: SystemStats.topProcs.length === 0
          text: "Collecting data…"
          color: Colors.shell.textMuted
          font.pixelSize: Options.textSize
        }

        Repeater {
          model: SystemStats.topProcs

          delegate: RowLayout {
            id: procRow
            required property var modelData
            Layout.fillWidth: true

            Text {
              Layout.fillWidth: true
              text: procRow.modelData.name
              elide: Text.ElideRight
              color: Colors.shell.text
              font.pixelSize: Options.textSize
            }
            Text {
              Layout.preferredWidth: 56
              horizontalAlignment: Text.AlignRight
              text: procRow.modelData.cpu.toFixed(1) + "%"
              color: Colors.shell.textMuted
              font.pixelSize: Options.textSize
            }
            Text {
              Layout.preferredWidth: 56
              horizontalAlignment: Text.AlignRight
              text: procRow.modelData.mem.toFixed(1) + "%"
              color: Colors.shell.textMuted
              font.pixelSize: Options.textSize
            }
          }
        }
      }
    }
  }
}
