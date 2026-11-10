pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.Services
import qs.Components

Scope {
  id: root

  property int minHeight: 20
  property int verticalMargin: 4
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
                                                   trayModule.visible ? trayModule.naturalHeight : 0,
                                                   // diskModule.naturalHeight,
                                                   // hardwareModule.naturalHeight,
                                                   // networkModule.naturalHeight,
                                                   clockModule.naturalHeight,
                                                   audioOutputModule.naturalHeight,
                                                   audioInputModule.naturalHeight,
                                                   batteryModule.visible
                                                   ? batteryModule.naturalHeight : 0,
                                                   idleModule.naturalHeight,
                                                   notificationModule.naturalHeight)

      implicitHeight: moduleHeight + root.verticalMargin

      exclusiveZone: implicitHeight

      // implicitHeight: root.height
      // focusable: false

      anchors {
        top: true
        left: true
        right: true
      }

      Item {
        id: barItem
        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        anchors.topMargin: root.verticalPadding
        anchors.bottomMargin: root.verticalPadding
        Row {
          id: leftRow
          anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            // verticalCenter: parent.verticalCenter
          }
          spacing: root.moduleSpacing
          ModuleContainer {
            id: workspaceModule
            height: barItem.height

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

          ModuleContainer {
            id: trayModule
            height: barItem.height

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

          // ModuleContainer {
          //   id: diskModule
          //   minHeight: panel.moduleHeight
          //   padding: root.modulePadding
          //   verticalPadding: root.verticalPadding
          //   moduleRadius: root.moduleRadius
          //
          //   DiskStats {}
          // }
          //
          // ModuleContainer {
          //   id: hardwareModule
          //   minHeight: panel.moduleHeight
          //   padding: root.modulePadding
          //   verticalPadding: root.verticalPadding
          //   moduleRadius: root.moduleRadius
          //
          //   HardwareStats {}
          // }
          //
          // ModuleContainer {
          //   id: networkModule
          //   minHeight: panel.moduleHeight
          //   padding: root.modulePadding
          //   verticalPadding: root.verticalPadding
          //   moduleRadius: root.moduleRadius
          //
          //   NetworkStats {}
          // }
        }

        ModuleContainer {
          id: clockModule
          anchors.centerIn: parent

          padding: root.modulePadding
          moduleRadius: root.moduleRadius
          height: barItem.height

          minHeight: panel.moduleHeight
          verticalPadding: root.verticalPadding

          Clock {
            dateFormat: "ddd, dd MMM"
            timeFormat: "HH:mm:ss"
          }
        }

        // Row {
        //   id: centerRightRow
        //
        //   spacing: root.moduleSpacing
        //   anchors.left: clockModule.right
        //   anchors.leftMargin: root.moduleSpacing
        // }

        Row {
          id: rightRow
          anchors {
            right: parent.right
            // verticalCenter: parent.verticalCenter

            top: parent.top
            bottom: parent.bottom
          }

          spacing: root.moduleSpacing
          ModuleContainer {
            id: audioOutputModule
            height: barItem.height

            minHeight: panel.moduleHeight
            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            AudioOutput {}
          }

          ModuleContainer {
            id: audioInputModule
            minHeight: panel.moduleHeight
            height: barItem.height

            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            AudioInput {}
          }
          ModuleContainer {
            id: batteryModule
            visible: Device.hasBattery
            minHeight: panel.moduleHeight
            height: barItem.height

            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius
            contentActive: battery.available

            Battery {
              id: battery
            }
          }

          ModuleContainer {
            id: idleModule
            minHeight: panel.moduleHeight
            height: barItem.height

            padding: root.modulePadding
            verticalPadding: root.verticalPadding
            moduleRadius: root.moduleRadius

            IdleInhibitorButton {}
          }
          ModuleContainer {
            id: notificationModule
            padding: root.modulePadding
            height: barItem.height

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
