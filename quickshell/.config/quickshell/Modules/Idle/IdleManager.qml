import QtQuick
import Quickshell
import Quickshell.Wayland

Scope {
  id: root

  property bool enabled: true

  function sh(cmd) {
    Quickshell.execDetached(["sh", "-c", cmd])
  }

  // 2.5 min: dim screen, keyboard backlight off
  IdleMonitor {
    enabled: root.enabled
    timeout: 150
    onIsIdleChanged: {
      if (isIdle) {
        root.sh("brightnessctl -s set 10")
        root.sh("brightnessctl -sd rgb:kbd_backlight set 0")
      } else {
        root.sh("brightnessctl -r")
        root.sh("brightnessctl -rd rgb:kbd_backlight")
      }
    }
  }

  // 5 min: lock
  IdleMonitor {
    enabled: root.enabled
    timeout: 300
    onIsIdleChanged: if (isIdle)
                       root.sh("loginctl lock-session")
  }

  // 10 min: screen off
  IdleMonitor {
    enabled: root.enabled
    timeout: 600
    onIsIdleChanged: {
      if (isIdle)
        root.sh("hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'")
      else
        root.sh("hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })' && brightnessctl -r")
    }
  }
}
