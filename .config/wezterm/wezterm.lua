local wezterm = require('wezterm')
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
    config = wezterm.config_builder()
end

-- Start config.

local keybinds = require('keybinds')

config.warn_about_missing_glyphs = false

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true

config.color_scheme = 'Atelierlakeside (dark) (terminal.sexy)'

config.window_background_opacity = 0.94
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

config.font = wezterm.font 'Hack'


-- Entering copy mode
config.disable_default_key_bindings = true
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables

return config
