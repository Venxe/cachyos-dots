-- Swayimg configuration

-- Rendering and Quality
swayimg.antialiasing = true
swayimg.exif_orientation = true
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.default_position = "center"

-- Image List: Automatically add neighboring files in same folder and monitor FS changes
swayimg.imagelist.adjacent = true
swayimg.imagelist.fsmon = true

-- Text Overlay (OSD): Hidden by default, 14px when toggled
swayimg.text.visible = false
swayimg.text.size = 14
swayimg.text.font = "sans-serif"
swayimg.text.padding = 8

-- Format-specific Quality
swayimg.format_conf = {
  raw = {
    enable = true,
    camera_wb = true
  }
}

-- Navigation: Left/Right arrows and Space to browse next/prev image
swayimg.viewer.on_key("right", function()
  swayimg.viewer.open("next")
end)

swayimg.viewer.on_key("left", function()
  swayimg.viewer.open("prev")
end)

swayimg.viewer.on_key("space", function()
  swayimg.viewer.open("next")
end)

-- Mouse Wheel: ScrollDown -> next image, ScrollUp -> previous image
swayimg.viewer.on_mouse("ScrollDown", function()
  swayimg.viewer.open("next")
end)

swayimg.viewer.on_mouse("ScrollUp", function()
  swayimg.viewer.open("prev")
end)

-- Rotate: 'r' for 90° clockwise, 'Shift+r' / 'R' for 90° counter-clockwise
swayimg.viewer.on_key("r", function()
  swayimg.viewer.rotate(90)
end)

swayimg.viewer.on_key({ "Shift+r", "Shift-r", "R" }, function()
  swayimg.viewer.rotate(270)
end)

-- Trash / Delete: Send current image to Trash (gio trash) and advance to next image
swayimg.viewer.on_key("Delete", function()
  local img = swayimg.viewer.get_image()
  if img and img.path then
    os.execute(string.format("gio trash %q", img.path))
    swayimg.imagelist.remove(img.path)
  end
end)

swayimg.gallery.on_key("Delete", function()
  local img = swayimg.gallery.get_image()
  if img and img.path then
    os.execute(string.format("gio trash %q", img.path))
    swayimg.imagelist.remove(img.path)
  end
end)

-- Toggle text overlay with 't'
swayimg.viewer.on_key("t", function()
  swayimg.text.visible = not swayimg.text.visible
end)

swayimg.gallery.on_key("t", function()
  swayimg.text.visible = not swayimg.text.visible
end)

-- Edit in Swappy with 'e'
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
