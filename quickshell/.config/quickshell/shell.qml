pragma ComponentBehavior: Bound

import Quickshell
import qs.Modules.Bar
import qs.Modules.Notifications
import qs.Modules.Stats
import qs.Modules.Idle
import qs.Modules.Lock
import qs.Modules.Osd
import qs.Modules.ControlCenter
import qs.Modules.Notifications
import qs.Modules.SessionMenu

ShellRoot {
  Bar {}
  // NotificationHub {}
  // NotificationPopups {}
  StatsPanel {}
  IdleManager {}
  LockScreen {}
  Osd {}
  ControlCenter {
    id: controlCenter
  }
  NotificationPopups {
    onOpenCenter: controlCenter.open = true
  }
  SessionMenu {}
}
