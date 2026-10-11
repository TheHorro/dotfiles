import QtQuick
import QtQuick.Layouts

RowLayout {
  id: root

  signal clicked
  spacing: 14

  HoverHandler {
    cursorShape: Qt.PointingHandCursor
  }
  TapHandler {
    onTapped: root.clicked()
  }
}
