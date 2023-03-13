local opts = require('kiser.utils').keymap_opts_with_defaults

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local api = require("nvim-tree.api")
vim.keymap.set('n', '<C-b>', api.tree.toggle, opts 'toggle nvim-tree')
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeFindFile<CR>", opts 'open current buffer in nvim-tree') -- open current buffer in NvimTree

local function on_attach(bufnr)
    -- Example keybind, prints the current node's absolute path.
    vim.keymap.set("n", "<C-P>", function()
        local node = api.tree.get_node_under_cursor()
        if node == nil then return end
        print(node.absolute_path)
    end, opts { buffer = bufnr, nowait = true, desc = "print the node's absolute path" })

    -- Telescope keybinds.
    local ok, builtin = pcall(require, 'telescope.builtin')
    if not ok then return end
    vim.keymap.set('n', '<leader>ff', function()
        local node = api.tree.get_node_under_cursor()
        if node == nil then return end
        local dir = vim.fn.fnamemodify(node.absolute_path, ':p:h')
        vim.notify('Got dir: ' .. dir)
        builtin.find_files({
            cwd = dir
        })
    end, opts { buffer = bufnr, desc = 'find file under directory' })
end

-- For complete list of available configuration options see :help nvim-tree-setup
-- For default mappings see :help nvim-tree-default-mappings
require("nvim-tree").setup {
    view = {
        number = true,
        relativenumber = true,
        width = 40, -- default is 30
    },
    on_attach = on_attach,
}

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
