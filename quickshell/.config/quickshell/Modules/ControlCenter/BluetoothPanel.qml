import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import qs.Services

Rectangle {
  id: root

  Layout.fillWidth: true
  implicitHeight: col.implicitHeight + 24
  radius: 16
  color: Colors.shell.card
  clip: true

  readonly property var adapter: Bluetooth.defaultAdapter
  property string autoConnect: ""     // address of a device we just started pairing

  // connected first, then paired, then nearby; unnamed devices are hidden
  readonly property ScriptModel deviceModel: ScriptModel {
    values: {
      const list = root.adapter ? root.adapter.devices.values.filter(d => d.paired || d.deviceName
                                                                          !== "") : []
      const rank = d => d.connected ? 0 : d.paired ? 1 : 2
      return list.slice().sort((a, b) => rank(a) - rank(b) || a.name.localeCompare(b.name))
    }
  }

  // scan only while the panel is open
  onVisibleChanged: {
    if (root.adapter && root.adapter.enabled)
      root.adapter.discovering = visible
  }
  Component.onDestruction: {
    if (root.adapter)
      root.adapter.discovering = false
  }

  ColumnLayout {
    id: col
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: 12
    }
    spacing: 8

    RowLayout {
      Layout.fillWidth: true
      spacing: 6

      Text {
        Layout.fillWidth: true
        text: !root.adapter ? "No Bluetooth adapter" : !root.adapter.enabled ? "Bluetooth is off" :
                                                                               "Bluetooth" + (
                                                                                 Controls.btConnected.length
                                                                                 > 0 ? "  ·  "
                                                                                       + Controls.btConnected.length
                                                                                       + " connected" :
                                                                                       "")
        color: Colors.shell.text
        font.pixelSize: 13
        font.weight: Font.DemiBold
        elide: Text.ElideRight
      }
      IconButton {
        visible: root.adapter && root.adapter.enabled
        icon: ""
        active: root.adapter && root.adapter.discovering
        onClicked: root.adapter.discovering = !root.adapter.discovering
      }
      IconButton {
        visible: root.adapter
        icon: ""
        onClicked: Controls.toggleBluetooth()
      }
    }

    ListView {
      Layout.fillWidth: true
      Layout.preferredHeight: Math.min(contentHeight, 220)
      visible: root.adapter && root.adapter.enabled
      clip: true
      spacing: 2
      model: root.deviceModel

      delegate: Rectangle {
        id: row
        required property var modelData
        readonly property var dev: modelData

        width: ListView.view.width
        height: 44
        radius: 10
        color: ma.containsMouse ? Colors.shell.cardHover : dev.connected ? Colors.shell.cardActive :
                                                                           "transparent"

        // finish the job once pairing succeeds
        Connections {
          target: row.dev
          function onPairedChanged() {
            if (row.dev.paired && root.autoConnect === row.dev.address) {
              root.autoConnect = ""
              row.dev.trusted = true
              row.dev.connect()
            }
          }
        }

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 8
          spacing: 10

          Item {
            Layout.preferredWidth: 26
            Layout.preferredHeight: 26

            Image {
              id: devIcon
              anchors.fill: parent
              visible: source !== "" && status !== Image.Error
              source: row.dev.icon !== "" ? Quickshell.iconPath(row.dev.icon, true) : ""
              sourceSize: Qt.size(52, 52)
              fillMode: Image.PreserveAspectFit
              asynchronous: true
            }
            Text {
              anchors.centerIn: parent
              visible: !devIcon.visible
              text: ""
              color: row.dev.connected ? Colors.shell.accent : Colors.shell.textMuted
              font.family: Options.fontFamily
              font.pixelSize: 16
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
              Layout.fillWidth: true
              text: row.dev.name !== "" ? row.dev.name : row.dev.address
              color: Colors.shell.text
              font.pixelSize: 13
              elide: Text.ElideRight
            }
            Text {
              Layout.fillWidth: true
              text: row.dev.pairing ? "Pairing…" : row.dev.state === BluetoothDeviceState.Connecting
                                      ? "Connecting…" : row.dev.state
                                        === BluetoothDeviceState.Disconnecting ? "Disconnecting…" :
                                                                                 row.dev.connected
                                                                                 ? "Connected" :
                                                                                   row.dev.paired
                                                                                   ? "Paired" :
                                                                                     "Available"
              color: row.dev.connected ? Colors.shell.accent : Colors.shell.textMuted
              font.pixelSize: 10
            }
          }

          Text {
            visible: row.dev.connected && row.dev.batteryAvailable
            text: Math.round(row.dev.battery * 100) + "%"
            color: Colors.shell.textMuted
            font.pixelSize: 11
          }

          IconButton {
            visible: row.dev.paired && (ma.containsMouse || hovered)
            size: 26
            icon: "\uf1f8"
            readonly property bool hovered: false
            onClicked: row.dev.forget()
          }
        }

        MouseArea {
          id: ma
          anchors.fill: parent
          hoverEnabled: true
          z: -1
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            if (row.dev.connected) {
              row.dev.disconnect()
            } else if (row.dev.paired) {
              row.dev.connect()
            } else {
              root.autoConnect = row.dev.address
              row.dev.pair()
            }
          }
        }
      }

      Text {
        anchors.centerIn: parent
        visible: root.deviceModel.values.length === 0
        text: root.adapter && root.adapter.discovering ? "Searching…" : "No devices"
        color: Colors.shell.textDisabled
        font.pixelSize: 12
      }
    }
  }
}
