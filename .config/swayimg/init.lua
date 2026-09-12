-- Swayimg configuration

-- Rendering & display
swayimg.antialiasing = true
swayimg.exif_orientation = true
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.default_position = "center"

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
swayimg.viewer.on_key("right", function()
  swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("left", function()
  swayimg.viewer.open("prev")
end)

swayimg.viewer.on_key("space", function()
  swayimg.viewer.open("next")
end)

swayimg.viewer.on_mouse("ScrollDown", function()
  swayimg.viewer.open("next")
end)

swayimg.viewer.on_mouse("ScrollUp", function()
  swayimg.viewer.open("prev")
end)

-- Rotation
swayimg.viewer.on_key("r", function()
  swayimg.viewer.rotate(90)
end)

swayimg.viewer.on_key({ "Shift+r", "Shift-r", "R" }, function()
  swayimg.viewer.rotate(270)
end)

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
  local target_path = table.remove(trash_history)
  local restored_path = nil

  if target_path then
    local cmd = string.format('TARGET=%q; URI=$(gio trash --list | awk -F\'\\t\' -v p="$TARGET" \'$2 == p { uri = $1 } END { if (uri) print uri }\'); if [ -n "$URI" ]; then gio trash --restore "$URI"; fi', target_path)
    os.execute(cmd)
    restored_path = target_path
  else
    local handle = io.popen("gio trash --list | head -n 1")
    if handle then
      local line = handle:read("*l")
      handle:close()
      if line and #line > 0 then
        local uri, orig = line:match("^(%S+)\t(.+)$")
        if uri and orig then
          os.execute(string.format("gio trash --restore %q", uri))
          restored_path = orig
        end
      end
    end
  end

  if restored_path then
    if swayimg.mode == "viewer" then
      swayimg.viewer.open_path(restored_path)
    elseif swayimg.mode == "gallery" then
      swayimg.imagelist.add(restored_path)
      swayimg.gallery.select_path(restored_path)
    end
  end
end

swayimg.viewer.on_key("Delete", function()
  trash_image(swayimg.viewer.get_image())
end)

swayimg.gallery.on_key("Delete", function()
  trash_image(swayimg.gallery.get_image())
end)

swayimg.viewer.on_key({ "Ctrl+z", "Ctrl-z", "Ctrl+Z", "Ctrl-Z", "u" }, function()
  restore_trashed_image()
end)

swayimg.gallery.on_key({ "Ctrl+z", "Ctrl-z", "Ctrl+Z", "Ctrl-Z", "u" }, function()
  restore_trashed_image()
end)

-- Toggle OSD
swayimg.viewer.on_key("t", function()
  swayimg.text.visible = not swayimg.text.visible
end)

swayimg.gallery.on_key("t", function()
  swayimg.text.visible = not swayimg.text.visible
end)

-- Edit in Swappy
swayimg.viewer.on_key("e", function()
  local img = swayimg.viewer.get_image()
  if img and img.path then
    os.execute(string.format("swappy -f %q &", img.path))
  end
end)

swayimg.gallery.on_key("e", function()
  local img = swayimg.gallery.get_image()
  if img and img.path then
    os.execute(string.format("swappy -f %q &", img.path))
  end
end)
