local wezterm = require('wezterm')
local act = wezterm.action

---@return boolean
local function is_work_laptop()
    return os.getenv('LOGNAME') == 'bskiser'
end

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

-- config.color_scheme = 'Atelierlakeside (dark) (terminal.sexy)'

config.window_background_opacity = 0.90
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}
config.background = {
    {
        source = {
            -- File = "/home/brandon/Pictures/8bitcat.jpg"
            File = "/home/brandon/Pictures/sakura.jpg"
        },
        hsb = {
            -- brightness = 0.09
            brightness = 0.02,
        }
    }
}

config.font = is_work_laptop() and wezterm.font_with_fallback({ 'Hack Nerd Font' })
    or wezterm.font_with_fallback({ 'Hack', 'Hack Nerd Font', 'FiraCode Nerd Font' })

-- Disables ligatures
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

-- Entering copy mode
config.disable_default_key_bindings = true
config.keys = keybinds.keys
config.key_tables = keybinds.key_tables

return config
