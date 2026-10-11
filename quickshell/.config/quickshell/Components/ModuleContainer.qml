pragma ComponentBehavior: Bound
import QtQuick
import qs.Services

Rectangle {
  id: root

  default property alias content: contentItem.data
  property int padding: 10            // horizontal
  property int verticalPadding: 4
  property int moduleRadius: 10
  property int minHeight: 0

  property bool hideWhenEmpty: false
  property bool contentActive: true     // modules can bind this
  property int minContentWidth: 0
  property int spacingBetween: 0

  property color backgroundColor: Qt.alpha(Colors.md3.background, 0.88)

  property color borderColor: Qt.alpha(Colors.md3.outline, 0.65)
  visible: !hideWhenEmpty || (contentActive && contentItem.implicitWidth > 0)

  readonly property int naturalHeight: (contentItem.module ? contentItem.module.implicitHeight : 0)
                                       + verticalPadding * 2

  implicitWidth: (contentItem.module ? contentItem.module.implicitWidth : 0) + padding * 2
  implicitHeight: Math.max(naturalHeight, minHeight)

  width: implicitWidth
  height: implicitHeight

  radius: Math.min(moduleRadius, height / 2)

  color: root.backgroundColor
  border.width: 1
  border.color: root.borderColor

  Item {
    id: contentItem
    anchors.fill: parent
    anchors.leftMargin: root.padding
    anchors.rightMargin: root.padding
    anchors.topMargin: 1               // stay inside the border
    anchors.bottomMargin: 1

    readonly property Item module: children.length > 0 ? children[0] : null

    onModuleChanged: if (module)
                       module.anchors.fill = contentItem

    // x: root.padding
    // y: Math.round((root.height - height) / 2)   // keep content centered when stretched
    //
    // // Its natural size comes only from the one module inserted in the
    // // default-property slot. No anchors and no childrenRect are involved.
    // implicitWidth: content.implicitWidth
    // implicitHeight: content.implicitHeight
    // width: implicitWidth
    // height: implicitHeight
    //
    // property Item content: children.length > 0 ? children[0] : null
  }
}
