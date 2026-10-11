import QtQuick
import QtQuick.Controls
import qs.Services

Rectangle {
  id: root

  signal clicked

  property string text: ""
  property string tooltip: ""

  property int size: 28
  property int iconSize: 15

  width: root.size
  height: root.size
  radius: 7

  color: tapHandler.pressed ? Colors.shell.cardActive : hoverHandler.hovered
                              ? Colors.shell.cardHover : "transparent"

  Text {
    anchors.centerIn: parent

    text: root.text
    color: Colors.shell.text

    font.family: Options.fontFamily
    font.pixelSize: root.iconSize
  }

  HoverHandler {
    id: hoverHandler
  }

  TapHandler {
    id: tapHandler

    onTapped: root.clicked()
  }

  ToolTip {
    visible: hoverHandler.hovered
    text: root.tooltip
    delay: 400
  }
}
