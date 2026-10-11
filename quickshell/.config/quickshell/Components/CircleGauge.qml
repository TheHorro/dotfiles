import QtQuick
import QtQuick.Shapes
import qs.Services

Item {
  id: root

  property real value: 0                 // 0..100
  property string label: ""
  property color color: Colors.shell.accent
  property color trackColor: Qt.alpha(Colors.shell.text, 0.12)
  property int size: 84
  property int lineWidth: 8

  property real shown: Math.max(0, Math.min(value, 100))
  Behavior on shown {
    NumberAnimation {
      duration: 350
      easing.type: Easing.OutCubic
    }
  }

  implicitWidth: size
  implicitHeight: size + caption.implicitHeight + 6

  Shape {
    id: ring
    width: root.size
    height: root.size
    layer.enabled: true
    layer.samples: 4

    ShapePath {
      strokeColor: root.trackColor
      strokeWidth: root.lineWidth
      fillColor: "transparent"
      PathAngleArc {
        centerX: root.size / 2
        centerY: root.size / 2
        radiusX: (root.size - root.lineWidth) / 2
        radiusY: radiusX
        startAngle: -90
        sweepAngle: 360
      }
    }

    ShapePath {
      strokeColor: root.shown > 0.5 ? root.color : "transparent"
      strokeWidth: root.lineWidth
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      PathAngleArc {
        centerX: root.size / 2
        centerY: root.size / 2
        radiusX: (root.size - root.lineWidth) / 2
        radiusY: radiusX
        startAngle: -90
        sweepAngle: 360 * root.shown / 100
      }
    }
  }

  Text {
    x: 0
    y: 0
    width: root.size
    height: root.size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: Math.round(root.value) + "%"
    color: Colors.shell.text
    font.pixelSize: Options.textSize + 4
    font.weight: Font.DemiBold
  }

  Text {
    id: caption
    anchors.top: ring.bottom
    anchors.topMargin: 6
    anchors.horizontalCenter: ring.horizontalCenter
    text: root.label
    color: root.color
    font.pixelSize: Options.textSize
    font.weight: Font.DemiBold
  }
}
