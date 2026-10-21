pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property string colorsPath: {
    const configHome = Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")
    return configHome + "/quickshell/generated/colors.json"
  }

  readonly property var defaults: ({
                                     mode: "dark",
                                     md3: {
                                       primary: "#a8c7fa",
                                       onPrimary: "#003258",
                                       primaryContainer: "#004a77",
                                       onPrimaryContainer: "#cce5ff",
                                       surface: "#101418",
                                       onSurface: "#e1e2e8",
                                       surfaceContainer: "#1c2025",
                                       surfaceBright: "#515147",
                                       surfaceContainerHigh: "#272a2f",
                                       surfaceContainerHighest: "#30343a",
                                       outline: "#8b919a",
                                       outlineVariant: "#43474e",
                                       inversePrimary: "#000000"
                                     },
                                     shell: {
                                       background: "#101418",
                                       foreground: "#e1e2e8",
                                       bar: "#1c2025",
                                       panel: "#272a2f",
                                       popup: "#30343a",
                                       overlay: "#000000",
                                       card: "#171b20",
                                       cardHover: "#1c2025",
                                       cardActive: "#272a2f",
                                       accent: "#a8c7fa",
                                       accentForeground: "#003258",
                                       accentMuted: "#004a77",
                                       accentMutedForeground: "#cce5ff",
                                       text: "#e1e2e8",
                                       textMuted: "#c3c7cf",
                                       textDisabled: "#8b919a",
                                       border: "#43474e",
                                       borderStrong: "#8b919a",
                                       success: "#8fd6a1",
                                       warning: "#f5c46b",
                                       danger: "#ffb4ab",
                                       dangerForeground: "#690005"
                                     }
                                   })

  property var data: defaults

  readonly property var md3: data.md3 ?? ({})
  readonly property var shell: data.shell ?? ({})
  readonly property bool isDark: data.mode === "dark"

  FileView {
    id: colorsFile

    path: root.colorsPath
    watchChanges: true

    onFileChanged: reload()

    onLoaded: {
      try {
        const parsed = JSON.parse(text())

        if (!parsed.md3 || !parsed.shell) {
          console.warn("Matugen colours lack md3 or shell objects:", root.colorsPath)
          return
        }

        root.data = {
          mode: parsed.mode ?? root.defaults.mode,
          md3: Object.assign({}, root.defaults.md3, parsed.md3),
          shell: Object.assign({}, root.defaults.shell, parsed.shell)
        }
      } catch (error) {
        console.warn("Could not parse Matugen colours:", root.colorsPath, error)
      }
    }
  }
}
