import QtQuick
import QtQuick.Layouts
import qs.Services

RowLayout {
  id: root

  property bool showTemps: true
  property bool clickable: true

  spacing: 14

  HoverHandler {
    enabled: root.clickable
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    enabled: root.clickable
    onTapped: SystemStats.togglePanel()
  }

  StatItem {
    icon: "󰍛"
    text: root.showTemps ? SystemStats.cpuText + "  " + SystemStats.cpuTempText :
                           SystemStats.cpuText
    sample: root.showTemps ? "100%  100°C" : "100%"
    textAlign: Text.AlignRight
  }

  StatItem {
    icon: "󰾆"
    text: SystemStats.memText
    sample: "999.9G"
    textAlign: Text.AlignRight
  }

  StatItem {
    icon: ""
    text: root.showTemps ? SystemStats.gpuText + "  " + SystemStats.gpuTempText :
                           SystemStats.gpuText
    sample: root.showTemps ? "100%  100°C" : "100%"
    textAlign: Text.AlignRight
  }
}
