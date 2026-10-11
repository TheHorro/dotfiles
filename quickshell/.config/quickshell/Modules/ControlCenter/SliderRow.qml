import QtQuick
import QtQuick.Layouts
import qs.Services

Item {
  id: root
  property string icon
  property real value: 0
  property bool dimmed: false
  signal moved(real v)
  signal iconClicked

  Layout.fillWidth: true
  implicitHeight: 40

  Rectangle {
    id: track
    anchors.fill: parent
    radius: height / 2
    color: Colors.shell.card
    clip: true

    Rectangle {
      width: Math.max(parent.height, parent.width * Math.min(1, root.value))
      height: parent.height
      radius: parent.radius
      color: root.dimmed ? Colors.shell.textDisabled : Colors.shell.accent
      Behavior on width {
        NumberAnimation {
          duration: 60
        }
      }
    }

    Text {
      id: ico
      width: parent.height
      height: parent.height
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter
      text: root.icon
      color: Colors.shell.background
      font.family: Options.fontFamily
      font.pixelSize: 18

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.iconClicked()
      }
    }

    MouseArea {
      anchors.left: ico.right
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      function setFrom(mx) {
        root.moved(Math.max(0, Math.min(1, (mx + ico.width) / track.width)))
      }
      onPressed: m => setFrom(m.x)
      onPositionChanged: m => {
        if (pressed)
          setFrom(m.x)
      }
    }
  }
}
