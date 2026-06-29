hl.on("hyprland.start", function()
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("udiskie -t")
end)
