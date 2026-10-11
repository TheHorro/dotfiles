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
    icon: AudioState.micIcon(AudioState.micMuted)
    text: Math.round(AudioState.micVolume * 100) + "%"
    sample: "100%"
    textAlign: Text.AlignRight
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.PointingHandCursor

    onClicked: mouse => {
      if (mouse.button === Qt.RightButton)
        Quickshell.execDetached(["pavucontrol", "-t", "4"])
      else
        AudioState.toggleSourceMute()
    }

    onWheel: wheel => AudioState.stepSource(wheel.angleDelta.y > 0 ? "up" : "down") + "%"
  }
}
