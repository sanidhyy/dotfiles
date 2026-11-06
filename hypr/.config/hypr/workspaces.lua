-- Use global workspace IDs instead of Omarchy's per-monitor blocks.
local M = {}

function M.focus(id)
  return hl.dsp.focus({
    workspace = tostring(id),
  })
end

function M.move_window(id, follow)
  return hl.dsp.window.move({
    workspace = tostring(id),
    follow = follow ~= false,
  })
end

function M.move_to_monitor(direction)
  return hl.dsp.workspace.move({
    monitor = direction,
  })
end

function M.move_window_to_monitor(direction)
  return hl.dsp.window.move({
    monitor = direction,
  })
end

o.workspaces = M
return M
