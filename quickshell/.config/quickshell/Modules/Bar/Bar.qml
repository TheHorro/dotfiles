pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services
import qs.Components

Scope {
  id: root

  property int minHeight: 28
  property int verticalMargin: 2
  property int horizontalPadding: 3
  property int verticalPadding: 2
  property int moduleSpacing: 5
  property int modulePadding: 4
  property int moduleRadius: 8

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: panel
      required property var modelData

      screen: modelData
      color: "transparent"
      readonly property int moduleHeight: Math.max(workspaceModule.naturalHeight,
                                                   trayModule.naturalHeight,
                                                   diskModule.naturalHeight,
                                                   hardwareModule.naturalHeight,
                                                   networkModule.naturalHeight,
                                                   clockModule.naturalHeight,
                                                   audioOutputModule.naturalHeight,
                                                   audioInputModule.naturalHeight,
                                                   idleModule.naturalHeight,
                                                   notificationModule.naturalHeight)

      implicitHeight: Math.max(root.minHeight, moduleHeight + root.verticalMargin * 2)

      exclusiveZone: implicitHeight

      // implicitHeight: root.height
      // focusable: false

      anchors {
        top: true
        left: true
        right: true
      }

      // exclusiveZone: root.height
      IdleInhibitor {
        window: panel
        enabled: IdleState.inhibit
      }

      Item {
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        Row {
          id: leftRow
          anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
          }
          spacing: root.moduleSpacing

          ModuleContainer {
            id: diskModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            DiskStats {}
          }

          ModuleContainer {
            id: hardwareModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            HardwareStats {}
          }

          ModuleContainer {
            id: networkModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            NetworkStats {}
          }
        }

        Row {
          id: centerLeftRow
          anchors.right: clockModule.left
          anchors.rightMargin: root.moduleSpacing

          spacing: root.moduleSpacing
          ModuleContainer {
            id: workspaceModule

            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            Workspaces {
              screen: panel.modelData

              buttonSpacing: 5
              showNumbers: true
            }
          }
        }

        ModuleContainer {
          id: clockModule
          anchors.centerIn: parent

          padding: root.modulePadding
          moduleRadius: root.moduleRadius
          minHeight: panel.moduleHeight
          verticalPadding: root.verticalPadding

          Clock {
            dateFormat: "ddd, dd MMM"
            timeFormat: "HH:mm:ss"
          }
        }
        Row {
          id: centerRightRow

          spacing: root.moduleSpacing
          anchors.left: clockModule.right
          anchors.leftMargin: root.moduleSpacing
          ModuleContainer {
            id: trayModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius
            // hideWhenEmpty: Options.trayHideWhenEmpty
            contentActive: tray.hasVisibleItems

            SystemTray {
              id: tray
              barWindow: panel
            }
          }
        }

        Row {
          id: rightRow
          anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
          }

          spacing: root.moduleSpacing
          ModuleContainer {
            id: audioOutputModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            AudioOutput {}
          }

          ModuleContainer {
            id: audioInputModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            AudioInput {}
          }

          ModuleContainer {
            id: idleModule
            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            IdleInhibitorButton {}
          }
          ModuleContainer {
            id: notificationModule
            padding: root.modulePadding
            moduleRadius: root.moduleRadius
            minHeight: panel.moduleHeight
            verticalPadding: root.verticalPadding

            NotificationButton {}
          }
        }
      }
    }
  }
}
