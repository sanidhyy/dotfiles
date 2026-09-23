-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Fix about window too small
o.window("org.omarchy.about", { size = { 920, 620 } })

-- Remove window transparency
hl.window_rule({
  match = { tag = "default-opacity" },
  opacity = "1 1",
})

-- Prevent dimming on fullscreen state, inactive photos, videos, and games
hl.window_rule({
  match = { fullscreen = true },
  no_dim = true,
})
hl.window_rule({ match = { content = "photo" }, no_dim = true })
hl.window_rule({ match = { content = "video" }, no_dim = true })
hl.window_rule({ match = { content = "game" }, no_dim = true })

-- VSCode/Cursor hide title bar (Update settings.json)
-- {
--   "window.titleBarStyle": "custom"
--   "window.newWindowDimensions": "maximized"
--   "window.restoreFullscreen": true
-- }
for _, class in ipairs({ "code", "cursor", "codium" }) do
  hl.window_rule({
    name = class .. "-hide-titlebar",
    match = { class = class },
    fullscreen_state = "0 3",
  })
end

-- Cisco Packet Tracer window rules
hl.window_rule({
  name = "packettracer",
  match = { class = "^PacketTracer$" },
  float = true,
  no_anim = true,
  no_blur = true,
  no_dim = true,
  no_shadow = true,
  opaque = true,
  immediate = true,
  border_size = 0,
  rounding = 0,
  decorate = false,
  nearest_neighbor = true,
  xray = true,
  min_size = { 1, 1 },
})

hl.window_rule({
  name = "packettracer-main",
  match = {
    class = "^PacketTracer$",
    title = "^Cisco Packet Tracer$",
  },
  keep_aspect_ratio = true,
  focus_on_activate = true,
})

local packettracer_min_sizes = {
  { name = "packettracer-preference", title = "^Preference$", size = { 486, 628 } },
  { name = "packettracer-router", title = "^.*outer.*$", size = { 486, 628 } },
  { name = "packettracer-switch", title = "^.*witch.*$", size = { 772, 700 } },
  { name = "packettracer-pc", title = "^.*PC.*$", size = { 807, 655 } },
  { name = "packettracer-save", title = "^.*Save File.*$", size = { 791, 648 } },
}

for _, rule in ipairs(packettracer_min_sizes) do
  hl.window_rule({
    name = rule.name,
    match = {
      class = "^PacketTracer$",
      title = rule.title,
    },
    min_size = rule.size,
  })
end

-- Bitwarden window rules
hl.window_rule({
    name = "bitwarden",
    match = {
        initial_title = "^_crx_nngceckbapebfimnlniiiahkandclblb$",
    },
    float = true,
    pin = true,
    size = { 375, 600 },
    center = true,
})
