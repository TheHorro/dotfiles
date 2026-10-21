import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Services

Scope {
  id: root

  readonly property bool active: !Controls.caffeine

  function sh(cmd) {
    Quickshell.execDetached(["sh", "-c", cmd])
  }

  // dim screen, keyboard backlight off
  IdleMonitor {
    enabled: root.active
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

  // lock
  IdleMonitor {
    enabled: root.active
    timeout: 600
    onIsIdleChanged: if (isIdle)
                       root.sh("loginctl lock-session")
  }

  // screen off
  IdleMonitor {
    enabled: root.active
    timeout: 600
    onIsIdleChanged: {
      if (isIdle)
        root.sh("hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'")
      else
        root.sh("hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })' && brightnessctl -r")
    }
  }
}
