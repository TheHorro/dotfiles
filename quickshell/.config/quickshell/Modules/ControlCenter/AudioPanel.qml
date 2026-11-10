import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.Services

Rectangle {
  id: root

  Layout.fillWidth: true
  implicitHeight: col.implicitHeight + 24
  radius: 16
  color: Colors.shell.card
  clip: true

  // real devices only: skip app streams and anything that isn't Audio/Sink or Audio/Source
  readonly property var sinks: Pipewire.nodes.values.filter(n => n.ready && n.audio && !n.isStream
                                                                 && n.isSink
                                                                 && n.properties["media.class"]
                                                                 === "Audio/Sink")

  readonly property var sources: Pipewire.nodes.values.filter(n => n.ready && n.audio && !n.isStream
                                                                   && !n.isSink
                                                                   && n.properties["media.class"]
                                                                   === "Audio/Source")

  component DeviceSection: ColumnLayout {
    id: sec
    property string title
    property var devices: []
    property var current: null
    signal picked(var node)

    Layout.fillWidth: true
    spacing: 2

    Text {
      text: sec.title
      color: Colors.shell.textMuted
      font.pixelSize: 11
      font.weight: Font.DemiBold
    }

    Repeater {
      model: sec.devices

      delegate: Rectangle {
        required property var modelData
        readonly property bool isCurrent: sec.current === modelData

        Layout.fillWidth: true
        implicitHeight: 36
        radius: 10
        color: ma.containsMouse ? Colors.shell.cardHover : isCurrent ? Colors.shell.cardActive :
                                                                       "transparent"

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: 10
          anchors.rightMargin: 10
          spacing: 8

          Text {
            text: isCurrent ? "\uf192" : "\uf10c"
            color: isCurrent ? Colors.shell.accent : Colors.shell.textMuted
            font.family: "Symbols Nerd Font Mono"
            font.pixelSize: 13
          }
          Text {
            Layout.fillWidth: true
            text: modelData.description || modelData.nickname || modelData.name
            color: Colors.shell.text
            font.pixelSize: 13
            elide: Text.ElideRight
          }
        }

        MouseArea {
          id: ma
          anchors.fill: parent
          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor
          onClicked: sec.picked(modelData)
        }
      }
    }

    Text {
      visible: sec.devices.length === 0
      text: "No devices"
      color: Colors.shell.textDisabled
      font.pixelSize: 12
    }
  }

  ColumnLayout {
    id: col
    anchors {
      left: parent.left
      right: parent.right
      top: parent.top
      margins: 12
    }
    spacing: 10

    DeviceSection {
      title: "Output"
      devices: root.sinks
      current: Pipewire.defaultAudioSink
      onPicked: node => Pipewire.preferredDefaultAudioSink = node
    }

    DeviceSection {
      title: "Input"
      devices: root.sources
      current: Pipewire.defaultAudioSource
      onPicked: node => Pipewire.preferredDefaultAudioSource = node
    }
  }
}
