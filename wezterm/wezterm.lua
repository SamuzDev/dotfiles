-- WezTerm (réplica de mi alacritty.toml)
local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Fuente
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 11.0

-- Ventana
config.window_background_opacity = 0.7
config.window_close_confirmation = "NeverPrompt"
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false

-- Tema: noctalia
config.colors = {
    foreground = "#e2e2e2",
    background = "#131313",
    cursor_bg = "#e2e2e2",
    cursor_fg = "#131313",
    cursor_border = "#e2e2e2",
    selection_bg = "#474747",
    selection_fg = "#c6c6c6",
    ansi = {
        "#474747", -- black
        "#ffb4ab", -- red
        "#ffffff", -- green
        "#c6c6c6", -- yellow
        "#e2e2e2", -- blue
        "#7d7d7d", -- magenta
        "#ababab", -- cyan
        "#e2e2e2", -- white
    },
    brights = {
        "#919191", -- black
        "#ffb4ab", -- red
        "#ffffff", -- green
        "#c6c6c6", -- yellow
        "#e2e2e2", -- blue
        "#7d7d7d", -- magenta
        "#ababab", -- cyan
        "#e2e2e2", -- white
    },
}

-- Shift+Enter -> ESC + CR (igual que en Alacritty)
config.keys = {
    { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b\r") },
}

return config
