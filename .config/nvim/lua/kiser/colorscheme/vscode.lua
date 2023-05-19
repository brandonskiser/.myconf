local ok, _ = pcall(require, 'vscode')
if not ok then
    print('vscode not installed')
end

-- Lua:
-- For dark theme (neovim's default)
vim.o.background = 'dark'
-- For light theme
-- vim.o.background = 'light'

local c = require('vscode.colors').get_colors()
local TRANSPARENT_BG = false
require('vscode').setup({
    -- Alternatively set style in setup
    -- style = 'light'

    -- Enable transparent background
    transparent = TRANSPARENT_BG,

    -- Enable italic comment
    italic_comments = true,

    -- Disable nvim-tree background color
    disable_nvimtree_bg = TRANSPARENT_BG,

    -- Override colors (see ./lua/vscode/colors.lua)
    color_overrides = {
        vscLineNumber = '#EEEEEE',
    },

    -- Override highlight groups (see ./lua/vscode/theme.lua)
    group_overrides = {
        -- this supports the same val table as vim.api.nvim_set_hl
        -- use colors from this colorscheme by requiring vscode.colors!
        Cursor = { fg = c.vscDarkBlue, bg = c.vscLightGreen, bold = true },
    }
})

require('vscode').load()

-- Makes linefeeds not so stupid bright. See :h 'listchars' for the highlight
-- groups used (NonText and Whitespace).
vim.api.nvim_set_hl(0, 'NonText', { fg = '#888888' })
vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#555555' })
