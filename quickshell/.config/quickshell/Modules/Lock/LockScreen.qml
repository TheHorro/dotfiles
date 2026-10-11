pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Scope {
  id: root

  property string wallpaper: "file://" + Quickshell.env("HOME")
                             + "/.config/hypr/wallpapers/cabin.jpg"

  function lock() {
    if (!sessionLock.locked)
      sessionLock.locked = true
  }

  LockContext {
    id: lockContext
    onUnlocked: sessionLock.locked = false
  }

  WlSessionLock {
    id: sessionLock

    LockSurface {
      context: lockContext
      wallpaper: root.wallpaper
    }
  }

  // qs ipc call lock lock
  IpcHandler {
    target: "lock"

    function lock(): void {
      root.lock()
    }

    function isLocked(): bool {
      return sessionLock.locked
    }
  }
}
