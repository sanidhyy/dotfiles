-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1
local omarchy_monitor_internal_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Configure a specific monitor.
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@180.00", position = "0x0", scale = omarchy_monitor_scale })
hl.monitor({ output = "eDP-1", mode = "1920x1200@120.00", position = "1920x150", scale = omarchy_monitor_internal_scale })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

-- Multi monitor workspace setup
for _, w in ipairs({
  { id = 1,  monitor = "HDMI-A-1", default = true },
  { id = 2,  monitor = "HDMI-A-1" },
  { id = 3,  monitor = "HDMI-A-1" },
  { id = 4,  monitor = "HDMI-A-1" },
  { id = 5,  monitor = "HDMI-A-1" },
  { id = 6,  monitor = "eDP-1", default = true },
  { id = 7,  monitor = "eDP-1" },
  { id = 8,  monitor = "eDP-1" },
  { id = 9,  monitor = "eDP-1" },
  { id = 10, monitor = "eDP-1" }, -- Super+0
}) do
  hl.workspace_rule({
    workspace = tostring(w.id),
    monitor = w.monitor,
    persistent = true,
    default = w.default,
  })
end

