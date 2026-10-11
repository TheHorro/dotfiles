import QtQuick
import qs.Services

Rectangle {
  id: root
  property string icon
  property bool active: false
  property int size: 34
  signal clicked

  implicitWidth: size
  implicitHeight: size
  radius: size / 2
  color: active ? Colors.shell.accent : ma.containsMouse ? Colors.shell.cardHover :
                                                           Colors.shell.card

  Text {
    anchors.centerIn: parent
    text: root.icon
    color: root.active ? Colors.shell.background : Colors.shell.text
    font.family: Options.fontFamily
    font.pixelSize: root.size * 0.47
  }

  MouseArea {
    id: ma
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: root.clicked()
  }
}
