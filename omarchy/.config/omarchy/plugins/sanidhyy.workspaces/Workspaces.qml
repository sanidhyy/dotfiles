import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property var barWindow: root.QsWindow ? root.QsWindow.window : null
  readonly property string screenName: barWindow && barWindow.screen
    ? String(barWindow.screen.name || "")
    : ""

  readonly property string dot: "\uDB85\uDCFB"

  readonly property bool dualMonitor: {
    var values = Hyprland.monitors.values
    var hasInternal = false
    var hasExternal = false
    for (var i = 0; i < values.length; i++) {
      var name = String(values[i].name || "")
      if (name.indexOf("eDP") === 0 || name.indexOf("LVDS") === 0 || name.indexOf("DSI") === 0)
        hasInternal = true
      else if (name !== "")
        hasExternal = true
    }
    return hasInternal && hasExternal
  }

  readonly property var workspaceIds: {
    if (root.screenName === "")
      return []
    if (!root.dualMonitor)
      return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    if (root.screenName === "eDP-1")
      return [6, 7, 8, 9, 10]
    return [1, 2, 3, 4, 5] // HDMI / DP
  }


  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }
    return null
  }

  function focusWorkspace(id) {
    var workspace = root.workspaceById(id)
    if (workspace) {
      workspace.activate()
      return
    }
    Hyprland.dispatch("hl.dsp.focus({ workspace = \"" + id + "\" })")
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds.length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds

      WidgetButton {
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0
        readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === modelData

        bar: root.bar
        text: root.dot
        active: focused
        activeColor: Color.accent
        opacity: focused ? 1 : (occupied ? 0.85 : 0.35)
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(14)
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
