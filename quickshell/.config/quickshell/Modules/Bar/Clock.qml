import QtQuick
import Quickshell
import qs.Services

Item {
  id: root

  property string dateFormat: "ddd, dd MMM"
  property string timeFormat: "HH:mm:ss"

  property string dateIcon: ""   // calendar
  property string timeIcon: ""   // clock

  property string iconFont: Options.fontFamily
  property int iconPixelSize: Options.iconSize
  property int fontPixelSize: Options.textSize
  property int fontWeight: Options.textWeight
  property color textColor: Colors.shell.text
  property color iconColor: Colors.shell.accent

  property int iconSpacing: 6      // icon <-> text
  property int sectionSpacing: 12  // date <-> time

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: root.sectionSpacing

    Row {
      spacing: root.iconSpacing
      anchors.verticalCenter: parent.verticalCenter

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.dateIcon
        color: root.iconColor
        font.family: root.iconFont
        font.pixelSize: root.iconPixelSize
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(clock.date, root.dateFormat)
        color: root.textColor
        font.pixelSize: root.fontPixelSize
        font.weight: root.fontWeight
      }
    }

    Row {
      spacing: root.iconSpacing
      anchors.verticalCenter: parent.verticalCenter

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.timeIcon
        color: root.iconColor
        font.family: root.iconFont
        font.pixelSize: root.iconPixelSize
      }

      Text {
        anchors.verticalCenter: parent.verticalCenter
        text: Qt.formatDateTime(clock.date, root.timeFormat)
        color: root.textColor
        font.pixelSize: root.fontPixelSize
        font.weight: root.fontWeight
      }
    }
  }
}
