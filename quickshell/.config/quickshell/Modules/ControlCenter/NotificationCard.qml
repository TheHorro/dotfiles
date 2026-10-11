import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.Services

Rectangle {
  id: card
  required property var modelData

  width: ListView.view ? ListView.view.width : 300
  implicitHeight: content.implicitHeight + 24
  height: implicitHeight
  radius: 14
  color: Colors.shell.card
  border.width: modelData.urgency === NotificationUrgency.Critical ? 1 : 0
  border.color: Colors.shell.danger

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.MiddleButton | Qt.RightButton
    onClicked: card.modelData.dismiss()
  }

  RowLayout {
    id: content
    anchors.fill: parent
    anchors.margins: 12
    spacing: 10

    Item {
      id: iconBox
      Layout.alignment: Qt.AlignTop
      Layout.preferredWidth: 36
      Layout.preferredHeight: 36

      // "" when the app sent no usable icon
      readonly property string resolved: {
        const n = card.modelData
        if (n.image !== "")
          return n.image
        if (n.appIcon === "")
          return ""
        if (n.appIcon.startsWith("/"))
          return "file://" + n.appIcon
        return Quickshell.iconPath(n.appIcon, true)
        // true = empty string if not in theme
      }

      readonly property bool useFallback: resolved === "" || img.status === Image.Error

      Image {
        id: img
        anchors.fill: parent
        visible: !iconBox.useFallback
        source: iconBox.resolved
        sourceSize: Qt.size(72, 72)
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
      }

      // Fallback: plain black glyph on a light tile
      Rectangle {
        anchors.fill: parent
        visible: iconBox.useFallback
        radius: 10
        color: Colors.shell.text

        Text {
          anchors.centerIn: parent
          text: "\uf0f3"
          color: "black"
          font.family: Options.fontFamily
          font.pixelSize: 20
        }
      }
    }
    ColumnLayout {
      Layout.fillWidth: true
      spacing: 3

      RowLayout {
        Layout.fillWidth: true
        Text {
          Layout.fillWidth: true
          text: card.modelData.appName
          color: Colors.shell.textMuted
          font.pixelSize: 11
          elide: Text.ElideRight
        }
        Text {
          text: "\uf00d"
          color: Colors.shell.textMuted
          font.family: Options.fontFamily
          font.pixelSize: 12
          MouseArea {
            anchors.fill: parent
            anchors.margins: -6
            cursorShape: Qt.PointingHandCursor
            onClicked: card.modelData.dismiss()
          }
        }
      }

      Text {
        Layout.fillWidth: true
        text: card.modelData.summary
        color: Colors.shell.text
        font.pixelSize: 14
        font.weight: Font.DemiBold
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
      }

      Text {
        Layout.fillWidth: true
        visible: text !== ""
        text: card.modelData.body
        textFormat: Text.StyledText
        color: Colors.shell.textMuted
        font.pixelSize: 12
        wrapMode: Text.Wrap
        maximumLineCount: 4
        elide: Text.ElideRight
      }

      Flow {
        Layout.fillWidth: true
        visible: card.modelData.actions.length > 0
        spacing: 6

        Repeater {
          model: card.modelData.actions
          delegate: Rectangle {
            required property var modelData
            implicitWidth: lbl.implicitWidth + 20
            implicitHeight: 26
            radius: 13
            color: abtn.containsMouse ? Colors.shell.cardActive : Colors.shell.cardHover

            Text {
              id: lbl
              anchors.centerIn: parent
              text: parent.modelData.text
              color: Colors.shell.text
              font.pixelSize: 11
            }
            MouseArea {
              id: abtn
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: parent.modelData.invoke()
            }
          }
        }
      }
    }
  }
}
