import QtQuick
import QtQuick.Controls
import Quickshell
import qs.Services

Item {
  id: root

  implicitWidth: item.implicitWidth
  implicitHeight: item.implicitHeight

  StatItem {
    id: item
    anchors.centerIn: parent
    iconFirst: true
    icon: AudioState.outputIconText
    text: AudioState.muted ? "" : Math.round(AudioState.volume * 100) + "%"
    sample: "100%"                       // keeps the width stable, like min-length
    textAlign: Text.AlignRight
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        Quickshell.execDetached(["pavucontrol", "-t", "3"])
      else
        AudioState.toggleSinkMute()
    }

    onWheel: wheel => AudioState.stepSink(wheel.angleDelta.y > 0 ? "up" : "down")
  }
}
