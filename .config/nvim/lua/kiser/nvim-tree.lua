-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

-- For complete list of available configuration options see :help nvim-tree-setup
-- For default mappings see :help nvim-tree-default-mappings
require("nvim-tree").setup {
    view = {
        number = true,
        relativenumber = true,
    },
}


local api = require("nvim-tree.api")
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-b>', api.tree.toggle, opts)
-- vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeOpen<CR>", opts)
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeFindFile<CR>", opts) -- open current buffer in NvimTree
-- vim.api.nvim_create_autocmd()

-- local devicons = require("nvim-web-devicons")
-- devicons.setup {
--     -- your personnal icons can go here (to override)
--     -- you can specify color or cterm_color instead of specifying both of them
--     -- DevIcon will be appended to `name`
--     -- override = {
--     --     zsh = {
--     --     icon = "",
--     --     color = "#428850",
--     --     cterm_color = "65",
--     --     name = "Zsh"
--     --     }
--     -- };
--     -- globally enable different highlight colors per icon (default to true)
--     -- if set to false all icons will have the default icon's color
--     color_icons = true;
--     -- globally enable default icons (default to false)
--     -- will get overriden by `get_icons` option
--     default = true;
-- }
