import QtQuick
import qs.Services

Rectangle {
  id: root

  property bool checked: false
  signal toggled

  implicitWidth: 46
  implicitHeight: 26
  radius: 13
  color: checked ? Colors.shell.accent : Colors.shell.card
  border.width: 1
  border.color: checked ? Colors.shell.accent : Colors.shell.border

  Behavior on color {
    ColorAnimation {
      duration: 120
    }
  }

  Rectangle {
    width: 18
    height: 18
    radius: 9
    y: 4
    x: root.checked ? parent.width - width - 4 : 4
    color: root.checked ? Colors.shell.accentForeground : Colors.shell.text

    Behavior on x {
      NumberAnimation {
        duration: 120
        easing.type: Easing.OutCubic
      }
    }
  }

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    onTapped: root.toggled()
  }
}
