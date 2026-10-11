import QtQuick
import QtQuick.Layouts
import qs.Services

RowLayout {
  id: root

  property string label: ""
  property real value: 0
  property bool muted: false
  signal moved(real v)

  spacing: 10
  Layout.fillWidth: true
  Layout.preferredHeight: 24

  Text {
    Layout.preferredWidth: 84
    text: root.label
    elide: Text.ElideRight
    color: Colors.shell.textMuted
    font.pixelSize: Options.textSize
  }

  Item {
    Layout.fillWidth: true
    Layout.preferredHeight: 20

    Rectangle {
      anchors.verticalCenter: parent.verticalCenter
      width: parent.width
      height: 6
      radius: 3
      color: Qt.alpha(Colors.shell.text, 0.15)

      Rectangle {
        width: parent.width * Math.max(0, Math.min(root.value, 1))
        height: parent.height
        radius: 3
        color: root.muted ? Colors.shell.textDisabled : Colors.md3.primary
      }
    }

    MouseArea {
      id: area
      anchors.fill: parent
      preventStealing: true
      cursorShape: Qt.PointingHandCursor

      function set(x) {
        root.moved(Math.max(0, Math.min(1, x / width)))
      }

      onPressed: mouse => set(mouse.x)
      onPositionChanged: mouse => {
        if (pressed)
          set(mouse.x)
      }
    }
  }

  Text {
    Layout.preferredWidth: 40
    horizontalAlignment: Text.AlignRight
    text: Math.round(root.value * 100) + "%"
    color: Colors.shell.textMuted
    font.pixelSize: Options.textSize
  }
}
