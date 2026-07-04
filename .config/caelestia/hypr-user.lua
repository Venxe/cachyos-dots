hl.on("hyprland.start", function()
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("equibop --start-minimized")
    hl.exec_cmd("steam -silent")
end)

hl.monitor({ output = "DP-1", mode = "2560x1440@165.08Hz", position = "auto", scale = 1, })

hl.env("XCURSOR_THEME", "Qogir-Dark")
hl.env("XCURSOR_SIZE", "24")

hl.config({
    input = {
        kb_layout = "tr",
    },
})
