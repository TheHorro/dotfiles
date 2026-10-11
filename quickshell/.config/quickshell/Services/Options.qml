pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
  readonly property string fontFamily: "CaskaydiaCove Nerd Font Mono"

  readonly property int textSize: 10
  readonly property int iconSize: 18
  readonly property int textWeight: Font.Bold

  readonly property int workspaceButtonSize: 20

  property int trayIconSize: 14
  property int trayIconPadding: 3      // hit area = iconSize + 2*padding
  property int traySpacing: 2
  property bool trayShowPassive: true
  property bool trayHideWhenEmpty: true
  property bool trayMenuOnLeftClick: false   // force the menu on left click
  property int trayMenuWidth: 200
  property int trayMenuItemHeight: 26
  property int trayMenuCloseDelay: 400
  property int trayTooltipDelay: 400
  property var trayHiddenIds: ["Xwayland Video Bridge"]
  property var trayOrder: []           // optional: ids listed first, in this order
}
