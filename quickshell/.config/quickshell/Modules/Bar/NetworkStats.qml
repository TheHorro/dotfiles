import QtQuick
import QtQuick.Layouts
import qs.Services

RowLayout {
  id: root

  property bool showAddress: true
  property bool showSpeed: true

  spacing: 14

  StatItem {
    icon: "󰌘"
    iconFirst: true
    text: root.showAddress ? SystemStats.netName + "  " + SystemStats.netIp : SystemStats.netName
  }

  StatItem {
    visible: root.showSpeed
    icon: "\uf0ec"
    iconFirst: true
    text: SystemStats.upText + " \uf062  " + SystemStats.downText + " \uf063"
    sample: "999.9kB/s \uf062  999.9kB/s \uf063"
  }
}
