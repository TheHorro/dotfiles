import QtQuick
import QtQuick.Layouts
import qs.Services

RowLayout {
  id: root

  property bool showPercent: true
  property bool showTotal: true

  spacing: 14

  StatItem {
    icon: "󰋊"
    iconFirst: true
    text: {
      let s = ""
      if (root.showPercent)
        s += SystemStats.diskText + "  "
      s += SystemStats.diskUsedText
      if (root.showTotal)
        s += " / " + SystemStats.diskTotalText
      return s
    }
    sample: (root.showPercent ? "100%  " : "") + "999.9G" + (root.showTotal ? " / 999.9G" : "")
  }
}
