import QtQuick
import QtQuick.Layouts
import qs.Services

Rectangle {
  id: root

  Layout.fillWidth: true
  implicitHeight: col.implicitHeight + 24
  radius: 16
  color: Colors.shell.card
  clip: true

  property string pending: ""     // secured network waiting for a password

  onVisibleChanged: if (visible) {
                      pending = ""
                      Controls.scan()
                    }

  function activate(n) {
    if (n.inUse) {
      Controls.disconnectWifi()
      return
    }
    const saved = Controls.savedConnections.indexOf(n.ssid) !== -1
    if (n.secure && !saved) {
      pending = n.ssid
      pwd.text = ""
      pwd.forceActiveFocus()
      return
    }
    pending = ""
    Controls.connectWifi(n.ssid, "")
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
        text: Controls.wifi ? "Wi-Fi" + (Controls.wifiSsid !== "" ? "  ·  " + Controls.wifiSsid : "") :
                              "Wi-Fi is off"
        color: Colors.shell.text
        font.pixelSize: 13
        font.weight: Font.DemiBold
        elide: Text.ElideRight
      }
      IconButton {
        icon: "\uf021"
        onClicked: Controls.scan()
      }
      IconButton {
        icon: "\uf011"
        onClicked: Controls.toggleWifi()
      }
    }

    ListView {
      Layout.fillWidth: true
      Layout.preferredHeight: Math.min(contentHeight, 200)
      visible: Controls.wifi
      clip: true
      spacing: 2
      model: Controls.wifiNetworks

      delegate: Rectangle {
        required property var modelData
        width: ListView.view.width
        height: 38
        radius: 10
        color: ma.containsMouse ? Colors.shell.cardHover : modelData.inUse
                                  ? Colors.shell.cardActive : "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          Text {
            text: "\uf1eb"
            color: modelData.inUse ? Colors.shell.accent : Colors.shell.text
            opacity: 0.4 + 0.6 * Math.min(modelData.signal, 100) / 100
            font.family: Options.fontFamily
            font.pixelSize: 15
          }
          Text {
            Layout.fillWidth: true
            text: modelData.ssid
            color: Colors.shell.text
            font.pixelSize: 13
            elide: Text.ElideRight
          }
          Text {
            visible: modelData.secure
            text: "\uf023"
            color: Colors.shell.textMuted
            font.family: Options.fontFamily
            font.pixelSize: 11
          }
          Text {
            visible: modelData.inUse
            text: "Connected"
            color: Colors.shell.accent
            font.pixelSize: 11
          }
        }

        MouseArea {
          id: ma
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: root.activate(modelData)
        }
      }

      Text {
        anchors.centerIn: parent
        visible: Controls.wifiNetworks.length === 0
        text: "No networks found"
        color: Colors.shell.textDisabled
        font.pixelSize: 12
      }
    }

    // Password prompt for new secured networks
    ColumnLayout {
      Layout.fillWidth: true
      visible: root.pending !== ""
      spacing: 4

      Text {
        text: "Password for " + root.pending
        color: Colors.shell.textMuted
        font.pixelSize: 11
      }

      Rectangle {
        Layout.fillWidth: true
        implicitHeight: 36
        radius: 10
        color: Colors.shell.cardHover
        border.width: 1
        border.color: Colors.shell.accent

        TextInput {
          id: pwd
          anchors.fill: parent
          anchors.margins: 10
          verticalAlignment: TextInput.AlignVCenter
          echoMode: TextInput.Password
          color: Colors.shell.text
          font.pixelSize: 13
          onAccepted: {
            Controls.connectWifi(root.pending, text)
            root.pending = ""
            text = ""
          }
          Keys.onEscapePressed: {
            root.pending = ""
            text = ""
          }
        }
      }
    }

    Text {
      Layout.fillWidth: true
      visible: Controls.netStatus !== ""
      text: Controls.netStatus
      color: Controls.connecting ? Colors.shell.textMuted : Colors.shell.danger
      font.pixelSize: 11
      wrapMode: Text.Wrap
    }
  }
}
