hl.on("hyprland.start", function()
    hl.exec_cmd("wl-clip-persist --clipboard regular")
    hl.exec_cmd("equibop")
    hl.exec_cmd("steam -silent")
    hl.exec_cmd("easyeffects --gapplication-service")
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
hl.window_rule({ match = { class = "(?i)localsend" }, float = true, size = "400 600" })
hl.window_rule({ match = { class = "(?i)qalculate-gtk" }, float = true })
