pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.Services

Item {
  id: root

  // Set this from the PanelWindow's screen/modelData.
  required property var screen

  property int buttonSize: Options.workspaceButtonSize
  property int buttonSpacing: 5
  property bool showNumbers: true

  property int buttonWidth: 24
  property int buttonHeight: 18
  property int buttonRadius: 5

  readonly property var monitor: Hyprland.monitorFor(root.screen)

  implicitWidth: workspaceRow.implicitWidth
  implicitHeight: workspaceRow.implicitHeight

  Row {
    id: workspaceRow

    anchors.verticalCenter: parent.verticalCenter
    spacing: root.buttonSpacing

    Repeater {
      model: Hyprland.workspaces

      delegate: Rectangle {
        required property var modelData

        readonly property var workspace: modelData

        // A workspace belongs to this bar only when it belongs to the
        // Hyprland monitor associated with this PanelWindow's screen.
        readonly property bool occupied: workspace.toplevels && workspace.toplevels.values
                                         && workspace.toplevels.values.length > 0
        readonly property bool onThisMonitor: root.monitor && workspace.monitor === root.monitor
        visible: onThisMonitor

        height: root.buttonHeight
        width: root.buttonWidth
        radius: root.buttonRadius

        color: {
          if (workspace.urgent)
            return Colors.shell.danger
          if (workspace.focused || (onThisMonitor && workspace.active))
            return Colors.md3.inversePrimary
          return "transparent"
        }
        border {
          width: occupied && !workspace.active ? 2 : 0
          color: Colors.md3.inversePrimary
        }

        Text {
          visible: root.showNumbers
          anchors.centerIn: parent

          text: workspace.name
          // text: {
          //   if (workspace.active)
          //     return "󰮯  " + workspace.name
          //   if (workspace.urgent)
          //     return "  " + workspace.name
          //   if (occupied)
          //     return "󰊠  " + workspace.name
          //   return "  " + workspace.name
          // }
          color: Colors.shell.text
          font.pixelSize: Options.textSize
          font.weight: Font.Bold
        }

        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor

          onClicked: workspace.activate()
        }
      }
    }
  }
}
