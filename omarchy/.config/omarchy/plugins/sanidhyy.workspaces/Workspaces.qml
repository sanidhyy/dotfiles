import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.workspaces"

  readonly property var monitor: {
    var window = root.QsWindow.window
    var screen = window ? window.screen : null
    return screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor
  }

  function activeWorkspaceId() {
    return root.monitor && root.monitor.activeWorkspace ? root.monitor.activeWorkspace.id : -1
  }

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
      if (name.indexOf("eDP") === 0 || name.indexOf("LVDS") === 0 || name.indexOf("DSI") === 0) hasInternal = true
      else if (name !== "") hasExternal = true
    }

    return hasInternal && hasExternal
  }

  readonly property var workspaceIds: {
    if (root.screenName === "") return []
    if (!root.dualMonitor) return [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    if (root.screenName === "eDP-1") return [6, 7, 8, 9, 10]

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

  // A wheel notch moves one entry along the row, and a touchpad adds up its
  // smaller deltas until they make a notch's worth.
  property real wheelAccumulator: 0

  function scrollWorkspaces(delta) {
    var wheel = Util.wheelSteps(root.wheelAccumulator, delta)
    root.wheelAccumulator = wheel.remainder
    if (wheel.steps === 0) return

    // Holds at either end rather than wrapping, so a touchpad swipe that runs
    // long stops on the last workspace.
    var ids = root.workspaceIds
    var index = ids.indexOf(root.activeWorkspaceId())
    if (index === -1) return
    var target = ids[Util.clamp(index - wheel.steps, 0, ids.length - 1)]
    if (target !== ids[index]) root.focusWorkspace(target)
  }

  function modeGlyph(mode) {
    if (mode === "scrolling") return "󰝥"
    if (mode === "floating") return "󰔶"
    return root.dot
  }

  // Read each displayed workspace's layout once per refresh.
  property var modeCache: ({})
  property var modeQueue: []
  property int modeGeneration: 0
  property int modeProcWorkspace: -1
  property int modeProcGeneration: 0

  function readMode() {
    if (modeProc.running || root.modeQueue.length === 0) return

    var pending = root.modeQueue.slice()
    var id = pending.shift()
    root.modeQueue = pending

    root.modeProcWorkspace = id
    root.modeProcGeneration = root.modeGeneration
    modeProc.command = ["omarchy-hyprland-workspace-layout-current", String(id)]
    modeProc.running = true
  }

  function refresh() {
    root.modeGeneration++
    root.modeCache = ({})
    root.modeQueue = root.workspaceIds.slice()
    readMode()
  }

  function cycleWorkspaceLayout(id) {
    if (!root.bar || id < 1) return

    var expression = "hl.dsp.focus({ workspace = \"" + id + "\" })"
    var command = "hyprctl dispatch " + Util.shellQuote(expression) + " >/dev/null" + " && omarchy-hyprland-workspace-layout-toggle"

    root.bar.run(command)
  }

  Component.onCompleted: refresh()
  onMonitorChanged: Qt.callLater(root.refresh)
  onWorkspaceIdsChanged: Qt.callLater(root.refresh)

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      var name = event ? String(event.name) : ""
      if (name === "configreloaded") root.refresh()
      // Quickshell credits every workspace switch to the focused monitor, as
      // the event doesn't say which one switched, and misses the workspace a
      // monitor falls back to when its own is moved away. Moving workspaces
      // between monitors switches the others, so ask Hyprland for the truth.
      // A workspace that changes number is only learned by asking too. Every
      // bar shares what Hyprland answers, so one asks after a plain switch.
      var switched = name === "workspacev2" && root.monitor !== null && root.monitor.focused
      if (switched || name === "moveworkspacev2" || name === "changeworkspaceid") {
        Hyprland.refreshMonitors()
        Hyprland.refreshWorkspaces()
      }
    }
  }

  Process {
    id: modeProc

    stdout: StdioCollector {
      onStreamFinished: {
        var mode = text.trim()
        // A read that started before a refresh may predate the change.
        if (!mode || root.modeProcGeneration !== root.modeGeneration) return

        // Replace the object so every glyph binding observes the update.
        var cache = {}
        for (var id in root.modeCache) cache[id] = root.modeCache[id]
        cache[root.modeProcWorkspace] = mode
        root.modeCache = cache
      }
    }

    onExited: {
      // Deferred: the process still reports running while it signals exit.
      Qt.callLater(root.readMode)
    }
  }

  // Super + L and the default layout change the mode without a focus change,
  // so they ask every bar to read it again.
  ShellIpc {
    target: "omarchy.workspaces"

    function refresh(): void { root.broadcast("refresh") }
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
        readonly property bool focused: root.activeWorkspaceId() === modelData

        bar: root.bar
        text: root.modeGlyph(root.modeCache[modelData] || "dwindle")
        active: focused
        activeColor: Commons.Color.accent
        opacity: focused ? 1 : (occupied ? 0.85 : 0.35)
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(14)
        fixedHeight: root.barSize
        onPressed: function(button) {
          if (button === Qt.LeftButton) root.focusWorkspace(modelData)
          else if (button === Qt.RightButton) root.cycleWorkspaceLayout(modelData)
        }
        onWheelMoved: function(delta) { root.scrollWorkspaces(delta) }
      }
    }
  }
}
