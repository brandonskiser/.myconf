local M = {}

---Sets the colorscheme using the base16 colorscheme passed in `palette` and assigns `g:colors_name` to `colors_name`.
--This just runs the same highlight overrides used across base16 gruvbox palettes.
---@param palette table
---@param colors_name string
function M.set_gruvbox_colorscheme(palette, colors_name)
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

    vim.g.colors_name = colors_name
end

return M
