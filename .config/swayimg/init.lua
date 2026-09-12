-- Swayimg configuration

-- Rendering & display
swayimg.antialiasing = true
swayimg.exif_orientation = true
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.default_position = "center"
swayimg.viewer.preload = 3
swayimg.viewer.history = 2

-- Image list
swayimg.imagelist.adjacent = true
swayimg.imagelist.fsmon = true

-- OSD
swayimg.text.visible = false
swayimg.text.size = 14
swayimg.text.font = "sans-serif"
swayimg.text.padding = 8

-- RAW support
swayimg.format_conf = {
  raw = {
    enable = true,
    camera_wb = true
  }
}

-- Navigation
local nav_locked = false

local function navigate(dir)
  if nav_locked then
    return
  end
  nav_locked = true
  swayimg.viewer.open(dir)
  swayimg.defer(0.07, function()
    nav_locked = false
  end)
end

swayimg.viewer.on_key({ "right", "space" }, function() navigate("next") end)
swayimg.viewer.on_key("left", function() navigate("prev") end)
swayimg.viewer.on_mouse("ScrollDown", function() navigate("next") end)
swayimg.viewer.on_mouse("ScrollUp", function() navigate("prev") end)

-- Zoom toggle on double click
local click_pending = false
local base_scale = nil

swayimg.viewer.on_image_change(function()
  base_scale = nil
end)

local function toggle_zoom()
  local curr_scale = swayimg.viewer.scale or 1.0
  if not base_scale then
    base_scale = curr_scale
  end

  if curr_scale > base_scale + 0.05 then
    swayimg.viewer.reset()
  else
    local mouse = swayimg.get_mouse_pos()
    local target = (curr_scale < 0.95) and 1.0 or (curr_scale * 2.0)
    swayimg.viewer.set_abs_scale(target, mouse.x, mouse.y)
  end
end

swayimg.viewer.on_mouse("MouseLeft", function()
  if click_pending then
    click_pending = false
    toggle_zoom()
  else
    click_pending = true
    swayimg.defer(0.3, function()
      click_pending = false
    end)
  end
end)

-- Rotation
swayimg.viewer.on_key("r", function() swayimg.viewer.rotate(90) end)
swayimg.viewer.on_key({ "Shift+r", "R" }, function() swayimg.viewer.rotate(270) end)

-- Trash & Undo
local trash_history = {}

local function trash_image(img)
  if not img or not img.path then
    return
  end
  local path = img.path
  table.insert(trash_history, path)
  os.execute(string.format("gio trash %q", path))
  swayimg.imagelist.remove(path)
end

local function restore_trashed_image()
  local path = table.remove(trash_history)
  if not path then
    return
  end
  local cmd = string.format('TARGET=%q; URI=$(gio trash --list | awk -F\'\\t\' -v p="$TARGET" \'$2 == p { uri = $1 } END { if (uri) print uri }\'); [ -n "$URI" ] && gio trash --restore "$URI"', path)
  os.execute(cmd)

  if swayimg.mode == "viewer" then
    swayimg.viewer.open_path(path)
  elseif swayimg.mode == "gallery" then
    swayimg.imagelist.add(path)
    swayimg.gallery.select_path(path)
  end
end

swayimg.viewer.on_key("Delete", function() trash_image(swayimg.viewer.get_image()) end)
swayimg.gallery.on_key("Delete", function() trash_image(swayimg.gallery.get_image()) end)
swayimg.viewer.on_key({ "Ctrl+z", "u" }, restore_trashed_image)
swayimg.gallery.on_key({ "Ctrl+z", "u" }, restore_trashed_image)

-- Toggle OSD
local function toggle_osd()
  swayimg.text.visible = not swayimg.text.visible
end
swayimg.viewer.on_key("t", toggle_osd)
swayimg.gallery.on_key("t", toggle_osd)

-- Edit in Swappy
local function edit_in_swappy(img)
  if img and img.path then
    os.execute(string.format("swappy -f %q &", img.path))
  end
end
swayimg.viewer.on_key("e", function() edit_in_swappy(swayimg.viewer.get_image()) end)
swayimg.gallery.on_key("e", function() edit_in_swappy(swayimg.gallery.get_image()) end)
