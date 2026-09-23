-- Change the default Omarchy look'n'feel.

-- Change cursor
-- For GTK:
--    gsettings set org.gnome.desktop.interface cursor-theme "catppuccin-mocha-dark-cursors"
--    gsettings set org.gnome.desktop.interface cursor-size 24
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("HYPRCURSOR_SIZE", "24")

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    -- No gaps between windows or borders.
    gaps_in = 0,
    -- gaps_out = 0,
    -- border_size = 0,

    -- reduce outer windows gap
    gaps_out = 4,

    -- Change to niri-like side-scrolling layout.
    -- layout = "scrolling",
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#decoration
hl.config({
  decoration = {
    -- Use round window corners.
    -- rounding = 8,

    active_opacity = 1,
    inactive_opacity = 1,

    -- Dim unfocused windows (0.0 = no dim, 1.0 = fully dimmed).
    dim_inactive = true,
    dim_strength = 0.15,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#animations
hl.config({
  animations = {
    -- Disable all animations.
    enabled = false,
  },
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#layout
-- hl.config({
--   layout = {
--     -- Avoid overly wide single-window layouts on wide screens.
--     single_window_aspect_ratio = { 1, 1 },
--   },
-- })

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
-- hl.config({
--   scrolling = {
--     -- See only one column per screen instead of two.
--     column_width = 0.97,
--   },
-- })

-- https://wiki.hypr.land/Configuring/Basics/Variables/#group
hl.config({
  group = {
    groupbar = {
      font_family = "JetBrainsMono Nerd Font",
      font_weight_active = "ultrabold",
      font_weight_inactive = "medium",
      indicator_gap = 0
    }
  }
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#cursor
hl.config({
  cursor = {
    inactive_timeout = 10
  }
})

-- https://wiki.hypr.land/Configuring/Basics/Variables/#misc
hl.config({
  misc = {
    middle_click_paste = false
  }
})
