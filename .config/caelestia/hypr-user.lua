hl.on("hyprland.start", function()
    hl.exec_cmd("sleep 1 && hyprshade on vibrance")
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("easyeffects --gapplication-service")
    hl.exec_cmd("fish -c wall")
    hl.exec_cmd("equibop")
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

hl.window_rule({ match = { class = "(?i)equibop" }, workspace = "special:communication silent" })

hl.window_rule({ match = { class = "thunar", title = "Rename.*" }, float = true })
hl.window_rule({ match = { class = "thunar", title = "Yeniden.*" }, float = true })
hl.window_rule({ match = { class = "(?i)qalculate-gtk" }, float = true })
hl.window_rule({ match = { class = "(?i)xarchiver" }, float = true, size = "800 600" })
hl.window_rule({ match = { class = "(?i)org.gnome.networkdisplays" }, float = true })
hl.window_rule({ match = { class = "(?i)localsend" }, float = true, size = "400 600" })
