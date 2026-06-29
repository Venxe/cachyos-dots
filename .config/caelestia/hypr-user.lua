hl.on("hyprland.start", function()
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("udiskie -t")
end)

hl.monitor({ output = "DP-1", mode = "2560x1440@165.08Hz", position = "auto", scale = 1, })

hl.config({
    input = {
        kb_layout = "tr",
    },
})
