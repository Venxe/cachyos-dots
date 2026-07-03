hl.on("hyprland.start", function()
    hl.exec_cmd("wl-clip-persist --clipboard regular")
end)

hl.monitor({ output = "DP-1", mode = "2560x1440@165.08Hz", position = "auto", scale = 1, })

hl.config({
    env = {
        "XCURSOR_THEME,Qogir-Dark",
        "XCURSOR_SIZE,24"
    },
    input = {
        kb_layout = "tr",
    },
})
