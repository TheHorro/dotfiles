import QtQuick
import qs.Services
import qs.Components

Item {
  id: root

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 5

    Text {
      text: Notifs.dnd ? "" : ""
      color: Notifs.dnd ? Qt.alpha(Colors.shell.text, 0.5) : Colors.shell.text
      font.family: Options.fontFamily
      font.pixelSize: Options.textSize + 1
    }

    Text {
      visible: Notifs.count > 0
      text: Notifs.count
      color: Colors.shell.text
      font.pixelSize: Options.textSize
      font.weight: Options.textWeight
    }
  }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        Notifs.dnd = !Notifs.dnd
      else
        Notifs.toggleHub()
    }
  }
}
