local palette = {
    -- Gruvbox dark hard
    -- Taken from https://github.com/dawikur/base16-gruvbox-scheme
    base00 = "#1d2021", -- ----
    base01 = "#3c3836", -- ---
    base02 = "#504945", -- --
    base03 = "#665c54", -- -
    base04 = "#bdae93", -- +
    base05 = "#d5c4a1", -- ++
    base06 = "#ebdbb2", -- +++
    base07 = "#fbf1c7", -- ++++
    base08 = "#fb4934", -- red
    base09 = "#fe8019", -- orange
    base0A = "#fabd2f", -- yellow
    base0B = "#b8bb26", -- green
    base0C = "#8ec07c", -- aqua/cyan
    base0D = "#83a598", -- blue
    base0E = "#d3869b", -- purple
    base0F = "#d65d0e"  -- brown
}

require('mini.base16').setup({
    palette = palette
})

-- Make comments more visible.
vim.api.nvim_set_hl(0, 'Comment', { fg = palette.base0B })
-- Make identifiers light instead of red.
vim.api.nvim_set_hl(0, 'Identifier', { fg = palette.base05 })

-- Treesitter highlights: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/CONTRIBUTING.md#highlights
-- Make treesitter "return" keyword the same as Keyword
local keyword = vim.api.nvim_get_hl(0, { name = 'Keyword' })
vim.api.nvim_set_hl(0, '@keyword.return', keyword)
-- Fix treesitter macro hl groups to link to Macro.
vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })
vim.api.nvim_set_hl(0, '@constant.macro', { link = 'Macro' })

vim.cmd('let g:colors_name = ' .. '"kiser-gruvbox"')
