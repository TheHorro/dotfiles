import QtQuick
import QtQuick.Layouts
import qs.Services

Rectangle {
  id: root

  property string icon: ""
  property bool active: false
  property bool confirm: false
  property bool armed: false
  signal activated

  Layout.fillWidth: true
  Layout.preferredHeight: 52
  radius: 12

  color: armed ? Colors.shell.danger : active ? Colors.shell.accentMuted : hover.hovered
                                                ? Colors.shell.cardHover : Colors.shell.card
  border.width: 1
  border.color: armed ? Colors.shell.danger : Colors.shell.border

  Text {
    anchors.centerIn: parent
    text: root.icon
    color: root.armed ? Colors.shell.dangerForeground : root.active
                        ? Colors.shell.accentMutedForeground : Colors.shell.text
    font.family: Options.fontFamily
    font.pixelSize: 18
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  Timer {
    id: armTimer
    interval: 3000
    onTriggered: root.armed = false
  }

  TapHandler {
    onTapped: {
      if (root.confirm && !root.armed) {
        root.armed = true
        armTimer.restart()
      } else {
        root.armed = false
        armTimer.stop()
        root.activated()
      }
    }
  }
}
