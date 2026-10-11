//@ pragma UseQApplication
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.Services

RowLayout {
  id: root

  // Window the tray lives in (the bar's PanelWindow), so popups can anchor to it
  required property var barWindow

  property int iconSize: Options.trayIconSize
  property int iconPadding: Options.trayIconPadding
  property bool showPassive: Options.trayShowPassive
  property var hiddenIds: Options.trayHiddenIds
  property bool menuOnLeftClick: Options.trayMenuOnLeftClick
  property int menuWidth: Options.trayMenuWidth
  property int menuItemHeight: Options.trayMenuItemHeight
  property int menuCloseDelay: Options.trayMenuCloseDelay
  property int tooltipDelay: Options.trayTooltipDelay
  property int popupGap: 4

  spacing: Options.traySpacing

  // Lets the container collapse when nothing is visible
  property int visibleCount: 0
  readonly property bool hasVisibleItems: visibleCount > 0

  // Shared popup state: only ONE menu and ONE tooltip exist for the whole tray
  property Item hoveredButton: null
  property Item menuButton: null
  property bool tipReady: false

  readonly property bool menuHovered: menuButton !== null && hoveredButton === menuButton

  function labelOf(item) {
    return item.tooltipTitle || item.title || item.id || ""
  }

  function isShown(item) {
    if (root.hiddenIds.indexOf(item.id) !== -1)
      return false
    if (!root.showPassive && item.status === Status.Passive)
      return false
    return true
  }

  function recount() {
    let n = 0
    for (let i = 0; i < repeater.count; i++) {
      const it = repeater.itemAt(i)
      if (it && it.shown)
        n++
    }
    visibleCount = n
  }

  // Position a popup directly below a tray button, in bar-window coordinates
  function placeBelow(popup, button) {
    const p = root.barWindow.contentItem.mapFromItem(button, 0, 0)
    popup.anchor.rect = Qt.rect(p.x, p.y, button.width, button.height + root.popupGap)
  }

  function closeMenu() {
    menuPopup.visible = false
    menuButton = null
  }

  function toggleMenu(button) {
    if (menuPopup.visible && menuButton === button) {
      closeMenu()
      return
    }
    tipReady = false
    menuButton = button
    placeBelow(menuPopup, button)
    menuPopup.visible = true
    closeTimer.restart()
  }

  Timer {
    id: closeTimer
    interval: root.menuCloseDelay
    onTriggered: if (!root.menuHovered && !popupHover.hovered)
                   root.closeMenu()
  }

  Timer {
    id: tipTimer
    interval: root.tooltipDelay
    onTriggered: root.tipReady = true
  }

  onHoveredButtonChanged: {
    tipReady = false
    if (hoveredButton)
      tipTimer.restart()
    else
      tipTimer.stop()
  }

  // Alphabetical, case-insensitive; falls back to id when the title is empty
  ScriptModel {
    id: sorted
    values: [...SystemTray.items.values].sort((a, b) => {
      const la = root.labelOf(a).toLowerCase()
      const lb = root.labelOf(b).toLowerCase()
      return la < lb ? -1 : la > lb ? 1 : 0
    })
  }

  Repeater {
    id: repeater
    model: sorted

    onItemAdded: root.recount()
    onItemRemoved: root.recount()

    delegate: MouseArea {
      id: trayButton
      required property SystemTrayItem modelData
      readonly property bool shown: root.isShown(modelData)
      visible: shown
      onShownChanged: root.recount()

      Layout.preferredWidth: root.iconSize + root.iconPadding * 2
      Layout.preferredHeight: root.iconSize + root.iconPadding * 2
      hoverEnabled: true
      acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
      cursorShape: Qt.PointingHandCursor

      onWheel: wheel => modelData.scroll(wheel.angleDelta.y, false)

      onContainsMouseChanged: {
        if (containsMouse) {
          root.hoveredButton = trayButton
          closeTimer.stop()
        } else {
          if (root.hoveredButton === trayButton)
            root.hoveredButton = null
          if (root.menuButton === trayButton)
            closeTimer.restart()
        }
      }

      onClicked: mouse => {
        switch (mouse.button) {
        case Qt.LeftButton:
          if (modelData.onlyMenu || root.menuOnLeftClick) {
            if (modelData.hasMenu)
              root.toggleMenu(trayButton)
          } else {
            modelData.activate()
          }
          break
        case Qt.RightButton:
          if (modelData.hasMenu)
            root.toggleMenu(trayButton)
          break
        case Qt.MiddleButton:
          modelData.secondaryActivate()
          break
        }
      }

      Rectangle {
        anchors.fill: parent
        radius: 4
        color: trayButton.containsMouse ? Colors.shell.cardHover : "transparent"
      }

      IconImage {
        anchors.centerIn: parent
        implicitSize: root.iconSize
        source: trayButton.modelData.icon
        asynchronous: true
      }
    }
  }

  // ---- Shared tooltip (one window for the whole tray) ----
  PopupWindow {
    id: tip

    readonly property string text: root.hoveredButton ? root.labelOf(root.hoveredButton.modelData) :
                                                        ""

    anchor.window: root.barWindow
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom

    visible: root.tipReady && root.hoveredButton !== null && !menuPopup.visible && text !== ""
    onVisibleChanged: if (visible && root.hoveredButton)
                        root.placeBelow(tip, root.hoveredButton)

    implicitWidth: label.implicitWidth + 16
    implicitHeight: label.implicitHeight + 8
    color: "transparent"

    Rectangle {
      anchors.fill: parent
      radius: 4
      color: Colors.shell.cardHover

      Text {
        id: label
        anchors.centerIn: parent
        color: Colors.shell.text
        text: tip.text
      }
    }
  }

  // ---- Shared menu (one window for the whole tray) ----
  QsMenuOpener {
    id: opener
    menu: root.menuButton ? root.menuButton.modelData.menu : null
  }

  PopupWindow {
    id: menuPopup

    anchor.window: root.barWindow
    anchor.edges: Edges.Bottom | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right

    visible: false
    implicitWidth: root.menuWidth
    implicitHeight: col.implicitHeight + 8
    color: "transparent"

    Rectangle {
      anchors.fill: parent
      radius: 6
      color: Colors.shell.card
      border.color: Colors.md3.outlineVariant

      HoverHandler {
        id: popupHover
        onHoveredChanged: {
          if (hovered)
            closeTimer.stop()
          else if (menuPopup.visible)
            closeTimer.restart()
        }
      }

      Column {
        id: col
        anchors.fill: parent
        anchors.margins: 4

        Repeater {
          model: opener.children

          delegate: Rectangle {
            id: entry
            required property QsMenuEntry modelData

            width: col.width
            height: modelData.isSeparator ? 5 : root.menuItemHeight
            radius: 4
            color: ma.containsMouse && !modelData.isSeparator ? Colors.shell.cardHover :
                                                                "transparent"

            Rectangle {
              visible: entry.modelData.isSeparator
              anchors.centerIn: parent
              width: parent.width - 8
              height: 1
              color: Colors.md3.outlineVariant
            }

            Text {
              visible: !entry.modelData.isSeparator
              anchors.verticalCenter: parent.verticalCenter
              anchors.left: parent.left
              anchors.leftMargin: 8
              anchors.right: parent.right
              anchors.rightMargin: 8
              elide: Text.ElideRight
              text: entry.modelData.text
              color: Colors.shell.text
              opacity: entry.modelData.enabled ? 1.0 : 0.4
            }

            MouseArea {
              id: ma
              anchors.fill: parent
              hoverEnabled: true
              enabled: !entry.modelData.isSeparator && entry.modelData.enabled
              onClicked: {
                entry.modelData.triggered()
                root.closeMenu()
              }
            }
          }
        }
      }
    }
  }
  Component.onCompleted: recount()
}
