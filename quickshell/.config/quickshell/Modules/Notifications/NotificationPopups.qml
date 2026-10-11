pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Services
import qs.Modules.ControlCenter

Scope {
  id: root

  // called when a popup is clicked, so it can open the control center
  signal openCenter

  PanelWindow {
    id: win

    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name)
            ?? Quickshell.screens[0]
    visible: Notifs.popups.length > 0 && !Notifs.centerOpen
    color: "transparent"

    anchors {
      top: true
      right: true
    }
    margins {
      top: 6
      right: 8
    }
    implicitWidth: 380
    implicitHeight: col.implicitHeight
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell:notifications"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
      id: col
      width: parent.width
      spacing: 8

      Repeater {
        model: Notifs.popupModel

        delegate: Item {
          id: item
          required property var modelData

          width: col.width
          height: card.height
          opacity: 0

          Behavior on opacity {
            NumberAnimation {
              duration: 180
            }
          }
          Component.onCompleted: opacity = 1

          readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

          NotificationCard {
            id: card
            modelData: item.modelData
            width: item.width
          }

          HoverHandler {
            id: hover
          }

          // left click opens the control center
          TapHandler {
            acceptedButtons: Qt.LeftButton
            onTapped: root.openCenter()
          }

          // popups stay in the control center when they time out
          Timer {
            interval: item.modelData.expireTimeout > 0 ? item.modelData.expireTimeout * 1000 : 6000
            running: !item.critical && !hover.hovered
            repeat: false
            onTriggered: Notifs.removePopup(item.modelData)
          }
        }
      }
    }
  }
}
