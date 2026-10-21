pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower

Singleton {
  id: root

  readonly property string hostname: hostFile.text().trim()
  readonly property bool hasBattery: UPower.displayDevice !== null && UPower.displayDevice.isPresent
  readonly property bool brightnessCrtl: false

  // per-host overrides for anything hardware can't tell you
  readonly property var profiles: ({
                                     "th-laptop": {
                                       barHeight: 24,
                                       brightnessCrtl: true
                                     },
                                     "Horro-arch": {
                                       barHeight: 26,
                                       brightnessCrtl: false
                                     }
                                   })
  readonly property var profile: profiles[hostname] ?? ({
                                                          barHeight: 24,
                                                          brightnessCrtl: false
                                                        })

  FileView {
    id: hostFile
    path: "/etc/hostname"
    blockLoading: true
  }
}
