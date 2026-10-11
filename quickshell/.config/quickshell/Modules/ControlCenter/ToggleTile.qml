import QtQuick
import QtQuick.Layouts
import qs.Services

Rectangle {
  id: root
  property string icon
  property string label
  property bool active: false
  signal clicked
  signal rightClicked

  Layout.fillWidth: true
  implicitHeight: 64
  radius: active ? 18 : 28
  color: active ? Colors.shell.accent : ma.containsMouse ? Colors.shell.cardHover :
                                                           Colors.shell.card

  Behavior on radius {
    NumberAnimation {
      duration: 150
    }
  }
  Behavior on color {
    ColorAnimation {
      duration: 150
    }
  }

  readonly property color fg: active ? Colors.shell.background : Colors.shell.text

  Column {
    anchors.centerIn: parent
    width: root.width - 16
    spacing: 4

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: root.icon
      color: root.fg
      font.family: Options.fontFamily
      font.pixelSize: 20
    }
    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter
      text: root.label
      color: root.fg
      font.pixelSize: 11
      elide: Text.ElideRight
    }
  }

  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor
    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        root.rightClicked()
      else
        root.clicked()
    }
  }
}
