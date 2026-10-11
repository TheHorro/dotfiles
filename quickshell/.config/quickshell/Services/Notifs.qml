pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

Singleton {
  id: root

  property bool dnd: false
  property bool centerOpen: false
  property int maxPopups: 4

  readonly property var list: server.trackedNotifications
  readonly property int count: server.trackedNotifications.values.length

  // visible popups, newest on top
  property var popups: []
  readonly property ScriptModel popupModel: ScriptModel {
    values: root.popups
  }

  function addPopup(n) {
    if (dnd || centerOpen)
      return
    popups = [n, ...popups.filter(p => p !== n)].slice(0, maxPopups)
  }

  function removePopup(n) {
    popups = popups.filter(p => p !== n)
  }

  function clearPopups() {
    popups = []
  }

  function clearAll() {
    clearPopups()
    server.trackedNotifications.values.slice().forEach(n => n.dismiss())
  }

  signal toggleCenter

  function toggleHub() {
    toggleCenter()
  }

  NotificationServer {
    id: server
    keepOnReload: true
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    actionIconsSupported: true
    imageSupported: true

    onNotification: n => {
      n.tracked = true
      n.closed.connect(() => root.removePopup(n))
      root.addPopup(n)
    }
  }
}
