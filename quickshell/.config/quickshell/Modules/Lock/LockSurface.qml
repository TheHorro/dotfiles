pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Services

WlSessionLockSurface {
  id: root

  required property LockContext context

  property string wallpaper: ""
  property int mainMonitorId: 0
  property real blurMain: 0.35           // 0..1
  property real blurOther: 0.35       // "slightly blurred"

  readonly property var mainMonitor: {
    const list = Hyprland.monitors.values
    for (let i = 0; i < list.length; i++)
      if (list[i].id === root.mainMonitorId)
        return list[i]
    return null
  }

  // Fall back to showing the UI everywhere if the main monitor isn't found
  readonly property bool isMain: !mainMonitor || (screen && mainMonitor.name === screen.name)

  color: Colors.shell.background

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  // Receives keystrokes on whichever surface the compositor gives keyboard focus to
  TextInput {
    id: input
    width: 1
    height: 1
    opacity: 0
    focus: true
    echoMode: TextInput.Password
    readOnly: root.context.unlockInProgress

    text: root.context.currentText
    onTextChanged: root.context.currentText = text
    onAccepted: root.context.tryUnlock()
    Keys.onEscapePressed: root.context.currentText = ""
    Component.onCompleted: forceActiveFocus()
  }

  Item {
    anchors.fill: parent

    // Wallpaper, blurred more on secondary screens
    Image {
      id: bg
      anchors.fill: parent
      anchors.margins: -24
      visible: false
      source: root.wallpaper !== "" ? root.wallpaper : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      Component.onCompleted: console.log("lock: wallpaper path =", root.wallpaper, "| source =",
                                         bg.source)

      onStatusChanged: {
        if (status === Image.Ready)
          console.log("lock: wallpaper loaded:", source)
        else if (status === Image.Error)
          console.warn("lock: wallpaper failed to load:", source)
      }
    }

    MultiEffect {
      anchors.fill: bg
      source: bg
      visible: root.wallpaper !== ""
      blurEnabled: blur > 0
      blur: root.isMain ? root.blurMain : root.blurOther
      blurMax: 48
      autoPaddingEnabled: false
    }

    Rectangle {
      anchors.fill: parent
      visible: root.wallpaper !== ""
      color: Qt.alpha(Colors.shell.overlay, 0.55)
    }

    MouseArea {
      anchors.fill: parent
      onClicked: input.forceActiveFocus()
    }

    // Lock UI: main monitor only
    ColumnLayout {
      anchors.centerIn: parent
      visible: root.isMain
      spacing: 14

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "HH:mm")
        color: Colors.shell.text
        font.pixelSize: 96
        font.weight: Font.Light
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: Qt.formatDateTime(clock.date, "dddd, d. MMMM")
        color: Colors.shell.textMuted
        font.pixelSize: 20
      }

      Item {
        Layout.preferredHeight: 24
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: "\uf023"
        color: Colors.shell.accent
        font.family: Options.fontFamily
        font.pixelSize: 28
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        text: Quickshell.env("USER")
        color: Colors.shell.text
        font.pixelSize: 16
        font.weight: Font.DemiBold
      }

      Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 320
        Layout.preferredHeight: 48
        radius: 14
        color: Qt.alpha(Colors.shell.card, 0.92)
        border.width: 2
        border.color: root.context.showFailure ? Colors.shell.danger : Colors.shell.accent

        Behavior on border.color {
          ColorAnimation {
            duration: 150
          }
        }

        Text {
          anchors.fill: parent
          anchors.leftMargin: 14
          anchors.rightMargin: 14
          horizontalAlignment: Text.AlignHCenter
          verticalAlignment: Text.AlignVCenter
          elide: Text.ElideLeft
          visible: root.context.currentText.length > 0
          text: "•".repeat(root.context.currentText.length)
          color: Colors.shell.text
          font.pixelSize: 18
          font.letterSpacing: 4
        }

        Text {
          anchors.centerIn: parent
          visible: root.context.currentText.length === 0
          text: "Password"
          color: Colors.shell.textDisabled
          font.pixelSize: 16
        }
      }

      Text {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredHeight: 20
        text: root.context.unlockInProgress ? "Authenticating…" : root.context.showFailure
                                              ? "Wrong password" : ""
        color: root.context.showFailure ? Colors.shell.danger : Colors.shell.textMuted
        font.pixelSize: 14
      }
    }
  }
}
//
// import QtQuick
// import QtQuick.Layouts
// import Quickshell
// import Quickshell.Wayland
// import qs.Services
//
// WlSessionLockSurface {
//   id: root
//
//   required property LockContext context
//
//   property string wallpaper: ""            // optional absolute path
//
//   color: Colors.shell.background
//
//   SystemClock {
//     id: clock
//     precision: SystemClock.Seconds
//   }
//
//   Item {
//     anchors.fill: parent
//
//     Image {
//       anchors.fill: parent
//       visible: root.wallpaper !== ""
//       source: root.wallpaper !== "" ? "file://" + root.wallpaper : ""
//       fillMode: Image.PreserveAspectCrop
//       asynchronous: true
//     }
//
//     Rectangle {
//       anchors.fill: parent
//       visible: root.wallpaper !== ""
//       color: Qt.alpha(Colors.shell.overlay, 0.55)
//     }
//
//     MouseArea {
//       anchors.fill: parent
//       onClicked: input.forceActiveFocus()
//     }
//
//     ColumnLayout {
//       anchors.centerIn: parent
//       spacing: 14
//
//       Text {
//         Layout.alignment: Qt.AlignHCenter
//         text: Qt.formatDateTime(clock.date, "HH:mm")
//         color: Colors.shell.text
//         font.pixelSize: 96
//         font.weight: Font.Light
//       }
//
//       Text {
//         Layout.alignment: Qt.AlignHCenter
//         text: Qt.formatDateTime(clock.date, "dddd, d. MMMM")
//         color: Colors.shell.textMuted
//         font.pixelSize: 20
//       }
//
//       Item {
//         Layout.preferredHeight: 24
//       }
//
//       Text {
//         Layout.alignment: Qt.AlignHCenter
//         text: "\uf023"
//         color: Colors.shell.accent
//         font.family: Options.fontFamily
//         font.pixelSize: 28
//       }
//
//       Text {
//         Layout.alignment: Qt.AlignHCenter
//         text: Quickshell.env("USER")
//         color: Colors.shell.text
//         font.pixelSize: 16
//         font.weight: Font.DemiBold
//       }
//
//       Rectangle {
//         Layout.alignment: Qt.AlignHCenter
//         Layout.preferredWidth: 320
//         Layout.preferredHeight: 48
//         radius: 14
//         color: Qt.alpha(Colors.shell.card, 0.92)
//         border.width: 2
//         border.color: root.context.showFailure ? Colors.shell.danger : input.activeFocus
//                                                  ? Colors.shell.accent : Colors.shell.border
//
//         Behavior on border.color {
//           ColorAnimation {
//             duration: 150
//           }
//         }
//
//         TextInput {
//           id: input
//           anchors.fill: parent
//           anchors.leftMargin: 14
//           anchors.rightMargin: 14
//           verticalAlignment: TextInput.AlignVCenter
//           horizontalAlignment: TextInput.AlignHCenter
//
//           echoMode: TextInput.Password
//           passwordCharacter: "•"
//           color: Colors.shell.text
//           font.pixelSize: 18
//           selectionColor: Colors.shell.accent
//           selectedTextColor: Colors.shell.accentForeground
//
//           focus: true
//           readOnly: root.context.unlockInProgress
//
//           text: root.context.currentText
//           onTextChanged: root.context.currentText = text
//           onAccepted: root.context.tryUnlock()
//           Keys.onEscapePressed: root.context.currentText = ""
//
//           Component.onCompleted: forceActiveFocus()
//         }
//
//         Text {
//           anchors.centerIn: parent
//           visible: input.text === ""
//           text: "Password"
//           color: Colors.shell.textDisabled
//           font.pixelSize: 16
//         }
//       }
//
//       Text {
//         Layout.alignment: Qt.AlignHCenter
//         Layout.preferredHeight: 20
//         text: root.context.unlockInProgress ? "Authenticating…" : root.context.showFailure
//                                               ? "Wrong password" : ""
//         color: root.context.showFailure ? Colors.shell.danger : Colors.shell.textMuted
//         font.pixelSize: 14
//       }
//     }
//   }
// }
