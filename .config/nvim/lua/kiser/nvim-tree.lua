local opts = require('kiser.utils').keymap_opts_with_defaults

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

local api = require("nvim-tree.api")
vim.keymap.set('n', '<C-b>', api.tree.toggle, opts 'toggle nvim-tree')
vim.api.nvim_set_keymap("n", "<leader>e", ":NvimTreeFindFile<CR>", opts 'open current buffer in nvim-tree') -- open current buffer in NvimTree

local function default_on_attach(bufnr)
    local opts = function(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node, opts('CD'))
    vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer, opts('Open: In Place'))
    vim.keymap.set('n', '<C-k>', api.node.show_info_popup, opts('Info'))
    vim.keymap.set('n', '<C-r>', api.fs.rename_sub, opts('Rename: Omit Filename'))
    vim.keymap.set('n', '<C-t>', api.node.open.tab, opts('Open: New Tab'))
    vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-x>', api.node.open.horizontal, opts('Open: Horizontal Split'))
    vim.keymap.set('n', '<BS>', api.node.navigate.parent_close, opts('Close Directory'))
    vim.keymap.set('n', '<CR>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<Tab>', api.node.open.preview, opts('Open Preview'))
    vim.keymap.set('n', '>', api.node.navigate.sibling.next, opts('Next Sibling'))
    vim.keymap.set('n', '<', api.node.navigate.sibling.prev, opts('Previous Sibling'))
    vim.keymap.set('n', '.', api.node.run.cmd, opts('Run Command'))
    vim.keymap.set('n', '-', api.tree.change_root_to_parent, opts('Up'))
    vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
    vim.keymap.set('n', 'bmv', api.marks.bulk.move, opts('Move Bookmarked'))
    vim.keymap.set('n', 'B', api.tree.toggle_no_buffer_filter, opts('Toggle No Buffer'))
    vim.keymap.set('n', 'c', api.fs.copy.node, opts('Copy'))
    vim.keymap.set('n', 'C', api.tree.toggle_git_clean_filter, opts('Toggle Git Clean'))
    vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts('Prev Git'))
    vim.keymap.set('n', ']c', api.node.navigate.git.next, opts('Next Git'))
    vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
    vim.keymap.set('n', 'D', api.fs.trash, opts('Trash'))
    vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand All'))
    vim.keymap.set('n', 'e', api.fs.rename_basename, opts('Rename: Basename'))
    vim.keymap.set('n', ']e', api.node.navigate.diagnostics.next, opts('Next Diagnostic'))
    vim.keymap.set('n', '[e', api.node.navigate.diagnostics.prev, opts('Prev Diagnostic'))
    vim.keymap.set('n', 'F', api.live_filter.clear, opts('Clean Filter'))
    vim.keymap.set('n', 'f', api.live_filter.start, opts('Filter'))
    vim.keymap.set('n', 'g?', api.tree.toggle_help, opts('Help'))
    vim.keymap.set('n', 'gy', api.fs.copy.absolute_path, opts('Copy Absolute Path'))
    vim.keymap.set('n', 'H', api.tree.toggle_hidden_filter, opts('Toggle Dotfiles'))
    vim.keymap.set('n', 'I', api.tree.toggle_gitignore_filter, opts('Toggle Git Ignore'))
    vim.keymap.set('n', 'J', api.node.navigate.sibling.last, opts('Last Sibling'))
    vim.keymap.set('n', 'K', api.node.navigate.sibling.first, opts('First Sibling'))
    vim.keymap.set('n', 'm', api.marks.toggle, opts('Toggle Bookmark'))
    vim.keymap.set('n', 'o', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', 'O', api.node.open.no_window_picker, opts('Open: No Window Picker'))
    vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
    vim.keymap.set('n', 'P', api.node.navigate.parent, opts('Parent Directory'))
    vim.keymap.set('n', 'q', api.tree.close, opts('Close'))
    vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
    vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
    vim.keymap.set('n', 's', api.node.run.system, opts('Run System'))
    vim.keymap.set('n', 'S', api.tree.search_node, opts('Search'))
    vim.keymap.set('n', 'U', api.tree.toggle_custom_filter, opts('Toggle Hidden'))
    vim.keymap.set('n', 'W', api.tree.collapse_all, opts('Collapse'))
    vim.keymap.set('n', 'x', api.fs.cut, opts('Cut'))
    vim.keymap.set('n', 'y', api.fs.copy.filename, opts('Copy Name'))
    vim.keymap.set('n', 'Y', api.fs.copy.relative_path, opts('Copy Relative Path'))
    vim.keymap.set('n', '<2-LeftMouse>', api.node.open.edit, opts('Open'))
    vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
end

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
    local function get_dir()
        local node = api.tree.get_node_under_cursor()
        if node == nil then return end
        return vim.fn.fnamemodify(node.absolute_path, ':p:h')
    end
    vim.keymap.set('n', '<leader>ff', function()
        local dir = get_dir()
        if not dir then return end
        vim.notify('Got dir: ' .. dir)
        builtin.find_files({
            cwd = dir
        })
    end, opts { buffer = bufnr, desc = 'find file under directory' })
    vim.keymap.set('n', '<leader>fg', function()
        local dir = get_dir()
        if not dir then return end
        builtin.live_grep({
            search = '',
            search_dirs = { dir }
        })
    end, opts { buffer = bufnr, desc = 'live grep under directory' })
    vim.keymap.set('n', '<leader>fG', function()
        local dir = get_dir()
        if not dir then return end
        local input_str = vim.fn.input('Search for regex >')
        if input_str == '' then return end
        builtin.grep_string({
            search = '',
            search_dirs = { dir }
        })
    end, opts { buffer = bufnr, desc = 'grep string under directory' })
end

-- For complete list of available configuration options see :help nvim-tree-setup
-- For default mappings see :help nvim-tree-default-mappings
require("nvim-tree").setup {
    view = {
        number = true,
        relativenumber = true,
        width = 40, -- default is 30
    },
    on_attach = function(bufnr)
        default_on_attach(bufnr)
        on_attach(bufnr)
    end
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
