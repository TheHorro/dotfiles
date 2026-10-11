import QtQuick
import QtQuick.Layouts
import qs.Services

Item {
  id: root

  property string icon: ""
  property string text: ""
  property string sample: ""            // widest expected text, reserves width
  property bool iconFirst: false
  property int textAlign: Text.AlignLeft

  property color textColor: Colors.shell.text
  property color iconColor: Colors.shell.textMuted
  property int iconPixelSize: Options.iconSize
  property int textPixelSize: Options.textSize
  property int spacing: 6
  property string iconFont: Options.fontFamily

  Layout.alignment: Qt.AlignVCenter

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  TextMetrics {
    id: metrics
    font.pixelSize: root.textPixelSize
    font.weight: Options.textWeight
    text: root.sample
  }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: root.spacing
    layoutDirection: root.iconFirst ? Qt.LeftToRight : Qt.RightToLeft

    Text {
      id: iconText
      anchors.verticalCenter: parent.verticalCenter
      visible: root.icon !== ""
      text: root.icon
      color: root.iconColor
      font.family: root.iconFont
      font.pixelSize: root.iconPixelSize
      height: root.iconPixelSize
      verticalAlignment: Text.AlignVCenter
    }

    Text {
      id: label
      anchors.verticalCenter: parent.verticalCenter
      width: Math.max(metrics.width, implicitWidth)
      horizontalAlignment: root.textAlign
      text: root.text
      color: root.textColor
      font.pixelSize: root.textPixelSize
      font.weight: Options.textWeight
    }
  }
}
