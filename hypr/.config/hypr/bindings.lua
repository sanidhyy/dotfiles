-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Application bindings
o.bind("SUPER + SHIFT + S", "Steam Big Picture", { launch = "steam-bigpicture.desktop" })

-- Web Apps bindings
o.bind("SUPER + SHIFT + W", "WhatsApp", { webapp = "https://web.whatsapp.com" })
o.bind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com" })
o.bind("SUPER + SHIFT + L", "Linear", { webapp = "https://linear.app" })
o.bind("SUPER + SHIFT + ALT + Y", "YouTube Music", { webapp = "https://music.youtube.com" })

-- Change omarchy menu shortcut
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Apps menu", "omarchy-menu toggle apps")

-- Change toggle waybar shortcut
hl.unbind("SUPER + ALT + SPACE")
o.bind_toggle("SUPER + ALT + SPACE", "Toggle top bar", "bar")

-- Launch about menu
o.bind("SUPER + SHIFT + I", "About", "omarchy-launch-about")

-- Volume step overrides
hl.unbind("XF86AudioRaiseVolume")
hl.unbind("XF86AudioLowerVolume")
o.bind("XF86AudioRaiseVolume", "Volume up", "omarchy-audio-output-volume +2", { locked = true, repeating = true })
o.bind("XF86AudioLowerVolume", "Volume down", "omarchy-audio-output-volume -2", { locked = true, repeating = true })

-- Brightness step overrides
hl.unbind("XF86MonBrightnessUp")
hl.unbind("XF86MonBrightnessDown")
o.bind("XF86MonBrightnessUp", "Brightness up", "omarchy-brightness-display +4%", { locked = true, repeating = true })
o.bind("XF86MonBrightnessDown", "Brightness down", "omarchy-brightness-display 4%-", { locked = true, repeating = true })

-- Separate brightness controls for internal and external display
o.bind("SUPER + F1", "Internal Brightness down", "omarchy-brightness-display --monitor eDP-1 4%-", { locked = true, repeating = true })
o.bind("SUPER + F2", "Internal Brightness up", "omarchy-brightness-display --monitor eDP-1 +4%", { locked = true, repeating = true })
o.bind("SUPER + ALT + F1", "External Brightness down", "omarchy-brightness-display --monitor HDMI-A-1 4%-", { locked = true, repeating = true })
o.bind("SUPER + ALT + F2", "External Brightness up", "omarchy-brightness-display --monitor HDMI-A-1 +4%", { locked = true, repeating = true })

-- Media controls for external keyboard
o.bind("SUPER + F9", "Switch audio output", "omarchy-audio-output-switch", { locked = true })

-- Lock screen shortcuts
o.bind(
  "SUPER + ESCAPE",
  "Turn off display",
  "omarchy-hyprland-session-locked && omarchy-shell lock blank",
  { locked = true, release = true }
)
o.bind("SUPER + R", "Reboot", "omarchy-hyprland-session-locked && omarchy-system-reboot", { locked = true })
o.bind("SUPER + S", "Shutdown", "omarchy-hyprland-session-locked && omarchy-system-shutdown", { locked = true })
o.bind("SUPER + SHIFT + ESCAPE", "Turn on display", "omarchy-shell lock wake", { locked = true })
