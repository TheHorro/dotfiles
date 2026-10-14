import QtQuick
import Quickshell.Services.UPower
import qs.Services

Item {
  id: root

  property bool showPercent: true
  property int lowThreshold: 20
  property string iconFont: Options.fontFamilyOptions.fontFamily
  property int iconPixelSize: Options.iconSize
  property int textPixelSize: Options.textSize
  property int spacing: 6

  readonly property var dev: UPower.displayDevice
  readonly property bool available: dev !== null && dev.isPresent

  // UPower reports 0..1 in Quickshell; the check also tolerates 0..100
  readonly property int percent: {
    if (!available)
      return 0
    const p = dev.percentage
    return Math.round(p <= 1 ? p * 100 : p)
  }

  readonly property bool charging: available && (dev.state === UPowerDeviceState.Charging || dev.state
                                                 === UPowerDeviceState.PendingCharge)
  readonly property bool full: available && dev.state === UPowerDeviceState.FullyCharged
  readonly property bool low: available && !charging && percent <= lowThreshold

  readonly property color tint: charging ? Colors.shell.success : low ? Colors.shell.danger :
                                                                        Colors.shell.text

  // battery glyph by level: empty, quarter, half, three quarters, full
  readonly property string batteryIcon: {
    if (percent >= 90)
      return ""
    if (percent >= 65)
      return ""
    if (percent >= 40)
      return ""
    if (percent >= 15)
      return ""
    return ""
  }

  // "1h 20m" for the estimate, or "" when unknown
  function formatTime(seconds) {
    if (!seconds || seconds <= 0)
      return ""
    const h = Math.floor(seconds / 3600)
    const m = Math.round((seconds % 3600) / 60)
    return h > 0 ? h + "h " + m + "m" : m + "m"
  }
  readonly property string estimate: !available ? "" : charging ? formatTime(dev.timeToFull) : formatTime(
                                                                    dev.timeToEmpty)

  visible: available
  implicitWidth: available ? row.implicitWidth : 0
  implicitHeight: row.implicitHeight

  Row {
    id: row
    anchors.centerIn: parent
    spacing: root.spacing

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.batteryIcon
      color: root.tint
      font.family: root.iconFont
      font.pixelSize: root.iconPixelSize
    }

    // charging indicator
    Text {
      anchors.verticalCenter: parent.verticalCenter
      visible: root.charging
      text: ""
      color: Colors.shell.success
      font.family: root.iconFont
      font.pixelSize: root.iconPixelSize
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      visible: root.showPercent
      text: root.percent + "%" + (hover.hovered && root.estimate !== "" ? "  ·  " + root.estimate :
                                                                          "")
      color: root.low ? Colors.shell.danger : Colors.shell.textMuted
      font.pixelSize: root.textPixelSize
      font.weight: Options.textWeight
    }
  }

  HoverHandler {
    id: hover
  }
}
