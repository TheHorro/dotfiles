import QtQuick
import qs.Services

Item {
  id: root

  property int iconPixelSize: Options.iconSize

  implicitWidth: icon.implicitWidth
  implicitHeight: root.iconPixelSize

  Text {
    id: icon
    anchors.centerIn: parent

    text: ""
    color: Controls.caffeine ? Colors.md3.primary : Qt.alpha(Colors.shell.text, 0.5)

    font.family: Options.fontFamily
    font.pixelSize: root.iconPixelSize
    height: root.iconPixelSize
    verticalAlignment: Text.AlignVCenter

    Behavior on color {
      ColorAnimation {
        duration: 150
      }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: Controls.caffeine = !Controls.caffeine
  }
}
