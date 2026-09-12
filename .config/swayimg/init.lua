-- Swayimg configuration

-- Rendering and Quality
swayimg.antialiasing = true
swayimg.exif_orientation = true
swayimg.viewer.default_scale = "optimal"
swayimg.viewer.default_position = "center"

-- Image List: Automatically add neighboring files in same folder for easy browsing
swayimg.imagelist.adjacent = true

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
