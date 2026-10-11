import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
  id: root

  signal unlocked

  property string currentText: ""
  property bool unlockInProgress: false
  property bool showFailure: false

  onCurrentTextChanged: showFailure = false

  function fail(reason) {
    unlockInProgress = false
    currentText = ""
    showFailure = true
  }

  function tryUnlock() {
    if (currentText === "" || unlockInProgress)
      return
    unlockInProgress = true
    if (!pam.start())
      fail("pam.start() returned false")
    else
      watchdog.restart()
  }

  Timer {
    id: watchdog
    interval: 15000
    onTriggered: {
      if (root.unlockInProgress) {
        pam.abort()
        root.fail("timeout")
      }
    }
  }

  PamContext {
    id: pam

    configDirectory: "../../pam"
    config: "password.conf"

    onPamMessage: {
      if (responseRequired)
        respond(root.currentText)
    }

    onCompleted: result => {
      watchdog.stop()
      if (result === PamResult.Success) {
        root.unlockInProgress = false
        root.currentText = ""
        root.unlocked()
      } else {
        root.fail("result " + result)
      }
    }

    onError: err => {
      watchdog.stop()
      root.fail("pam error " + err)
    }
  }
}
