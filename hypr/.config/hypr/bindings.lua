-- Keep only your personal keybinding overrides here. Add new bindings with
-- o.bind or replace defaults with o.rebind.

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

-- Change an existing binding. o.rebind takes the same arguments as o.bind.
-- This example replaces the default file manager with Flea.
-- o.rebind("SUPER + SHIFT + F", "File manager", { launch = "flea" })

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, { panel = "omarchy.emojis" })

-- Application bindings
o.rebind("SUPER + CTRL + RETURN", "Herdr", { omarchy = "terminal-herdr" })
o.rebind("SUPER + SHIFT + S", "Steam Big Picture", { launch = "steam-bigpicture.desktop" })
o.rebind("SUPER + SHIFT + W", "WhatsApp", { launch = "zapfast.desktop" })
o.rebind("SUPER + SHIFT + E", "VSCodium", { launch = "codium.desktop" })

-- Web Apps bindings
o.rebind("SUPER + SHIFT + Y", "YouTube", { webapp = "https://youtube.com" })
o.rebind("SUPER + SHIFT + A", "ChatGPT", { webapp = "https://chatgpt.com" })
o.bind("SUPER + SHIFT + L", "Linear", { webapp = "https://linear.app" })
o.bind("SUPER + SHIFT + ALT + Y", "YouTube Music", { webapp = "https://music.youtube.com" })

-- Change omarchy menu shortcut
o.rebind("SUPER + SHIFT + SPACE", "Omarchy menu", { menu = "root" })
o.rebind("SUPER + SPACE", "Apps menu", { menu = "apps" })

-- Change toggle top bar shortcut
o.rebind("SUPER + ALT + SPACE", "Toggle top bar", "omarchy-toggle-bar")

-- Notification shortcuts overrides
o.rebind( "SUPER + comma", "Dismiss last notification", { ipc = "notifications.dismissOne" })
o.rebind("SUPER + ALT + comma", "Dismiss, invoke, or focus last notification", { ipc = "notifications.act" })

-- Launch about menu
o.rebind("SUPER + SHIFT + I", "About", "omarchy-launch-about")

-- Toggle hyprland keybindings (e.g., for windows vm)
o.rebind("SUPER + ALT + K", "Toggle Keybindings", hl.dsp.submap("passthrough"))
hl.define_submap("passthrough", function()
    hl.bind("SUPER + ALT + K", hl.dsp.submap("reset"))
end)

-- Toggle window transparency and dimming shortcut
o.rebind("SUPER + BACKSPACE", "Toggle window transparency and dimming", "omarchy-hyprland-window-transparency-dim-toggle")

-- Toggle nightlight
o.bind("SUPER + ALT + N", "Toggle nightlight", "omarchy-toggle-nightlight-4500")

-- Volume step overrides
o.rebind("XF86AudioRaiseVolume", "Volume up", "omarchy-audio-output-volume-boost raise", { locked = true, repeating = true })
o.rebind("XF86AudioLowerVolume", "Volume down", "omarchy-audio-output-volume-boost lower", { locked = true, repeating = true })

-- Precise volume step overrides
o.rebind("ALT + XF86AudioRaiseVolume", "Volume up precise", "omarchy-audio-output-volume-boost +1", { locked = true, repeating = true })
o.rebind("ALT + XF86AudioLowerVolume", "Volume down precise", "omarchy-audio-output-volume-boost -1", { locked = true, repeating = true })

-- Brightness step overrides
o.rebind("XF86MonBrightnessUp", "Brightness up", "omarchy-brightness-display +4%", { locked = true, repeating = true })
o.rebind("XF86MonBrightnessDown", "Brightness down", "omarchy-brightness-display 4%-", { locked = true, repeating = true })

-- Separate brightness controls for internal and external display
o.bind("SUPER + F1", "Internal Brightness down", "omarchy-brightness-display --monitor eDP-1 4%-", { locked = true, repeating = true })
o.bind("SUPER + F2", "Internal Brightness up", "omarchy-brightness-display --monitor eDP-1 +4%", { locked = true, repeating = true })
o.bind("SUPER + ALT + F1", "External Brightness down", "omarchy-brightness-display --monitor HDMI-A-1 4%-", { locked = true, repeating = true })
o.bind("SUPER + ALT + F2", "External Brightness up", "omarchy-brightness-display --monitor HDMI-A-1 +4%", { locked = true, repeating = true })

-- Media controls for external keyboard
o.bind("SUPER + F9", "Switch audio output", "omarchy-audio-output-switch", { locked = true })

-- Lock screen shortcuts
o.bind("SUPER + ESCAPE", "Turn off display", "omarchy-hyprland-session-locked && omarchy-shell lock blank", { locked = true, release = true })
o.bind("SUPER + R", "Reboot", "omarchy-hyprland-session-locked && omarchy-system-reboot", { locked = true })
o.bind("SUPER + S", "Shutdown", "omarchy-hyprland-session-locked && omarchy-system-shutdown", { locked = true })
o.bind("SUPER + SHIFT + ESCAPE", "Turn on display", "omarchy-hyprland-session-locked && omarchy-shell lock wake", { locked = true })
