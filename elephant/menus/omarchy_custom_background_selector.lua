Name = "omarchyCustomBackgroundSelector"
NamePretty = "Omarchy Custom Background Selector"
Cache = false
HideFromProviderlist = true
SearchName = true

local home = os.getenv("HOME")

local IMAGE_EXTS = {"jpg", "jpeg", "png", "gif", "bmp", "webp"}
local VIDEO_EXTS = {}

-- Fetch video extensions from constants file
local ext_file = io.open(home .. "/.config/omarchy-custom/constants/video_exts.list", "r")
if ext_file  then
  for line in ext_file:lines() do
    -- Strip whitespaces
    local ext = line:match("^%s*(.-)%s*$")
    if ext ~= "" then
      table.insert(VIDEO_EXTS, ext)
    end
  end

  ext_file:close()
end

local function GetFindConditions()
  local conditions = {}
  for _, ext in ipairs(IMAGE_EXTS) do table.insert(conditions, "-name '*." .. ext .. "'") end
  for _, ext in ipairs(VIDEO_EXTS) do table.insert(conditions, "-name '*." .. ext .. "'") end

  return table.concat(conditions, " -o ")
end

local function FileExists(name)
  local f = io.open(name, "r")
  if f ~= nil then io.close(f) return true else return false end
end

local function ShellEscape(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

function FormatName(filename)
  -- Remove leading number and dash
  local name = filename:gsub("^%d+", ""):gsub("^%-", "")
  -- Remove extension
  name = name:gsub("%.[^%.]+$", "")
  -- Replace dashes with spaces
  name = name:gsub("-", " ")
  -- Capitalize each word
  name = name:gsub("%S+", function(word)
    return word:sub(1, 1):upper() .. word:sub(2):lower()
  end)
  return name
end

function GetEntries()
  local entries = {}

  -- lookup table for checking video
  local is_video_ext = {}
  for _, ext in ipairs(VIDEO_EXTS) do
    is_video_ext[ext] = true
  end

  -- Read current theme name
  local theme_name_file = io.open(home .. "/.config/omarchy/current/theme.name", "r")
  local theme_name = theme_name_file and theme_name_file:read("*l") or nil
  if theme_name_file then
    theme_name_file:close()
  end

  -- Directories to search
  local dirs = {
    home .. "/.config/omarchy/current/theme/backgrounds",
    home .. "/Wallpapers",
  }
  if theme_name then
    table.insert(dirs, home .. "/.config/omarchy/backgrounds/" .. theme_name)
  end

  -- Track added files to avoid duplicates
  local seen = {}

  for _, bg_dir in ipairs(dirs) do
    local find_cmd = "find " .. ShellEscape(bg_dir) .. " -maxdepth 1 -type f \\( " .. GetFindConditions() .. " \\) 2>/dev/null | sort"
    local handle = io.popen(find_cmd)

    if handle then
      for background in handle:lines() do
        local filename = background:match("([^/]+)$")

        if filename and not seen[filename] then
          seen[filename] = true

          local display_text = FormatName(filename)
          local preview_path = background

          local ext = filename:match("%.([^%.]+)$")

          if ext and is_video_ext[ext] then
            display_text = " " .. display_text

            local cache_dir = home .. '/.cache/omarchy-custom/live_thumbs/'
            preview_path = cache_dir .. filename:gsub("%.%w+$", ".jpg")

            if not FileExists(preview_path) then
              os.execute("mkdir -p " .. ShellEscape(cache_dir))
              os.execute("ffmpegthumbnailer -i " .. ShellEscape(background) .. " -o " .. ShellEscape(preview_path) .. " -s 320 -q 8")
            end
          end

          table.insert(entries, {
            Text = display_text,
            Value = background,
            Actions = {
              activate = home .. "/.local/bin/omarchy-custom-theme-bg-set " .. ShellEscape(background),
            },
            Preview = preview_path,
            PreviewType = "file",
          })
        end
      end
      handle:close()
    end
  end

  return entries
end
