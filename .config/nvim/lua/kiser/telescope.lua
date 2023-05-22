local opts = require('kiser.utils').keymap_opts_with_defaults

-- show line numbers in file preview
vim.cmd "autocmd User TelescopePreviewerLoaded setlocal number"

local layout_actions = require('telescope.actions.layout')
require('telescope').setup {
    defaults = {
        mappings = {
            i = {
                ["<C-h>"] = layout_actions.toggle_preview
            },
            n = {
                ["<C-h>"] = layout_actions.toggle_preview
            }
        }
    },
    extensions = {
        fzf = {
            fuzzy = true, -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')

-- Telescope keybindings
local builtin = require("telescope.builtin")
-- local get_dropdown = require('telescope.themes').get_dropdown()
-- local function builtin_wrapper(func, theme) return function() func(theme) end end
-- vim.keymap.set('n', '<leader>ff', builtin_wrapper(builtin.find_files, get_dropdown), opts 'find files')
vim.keymap.set('n', '<leader>ff', builtin.find_files, opts 'find files')
vim.keymap.set('n', '<leader>fg', builtin.live_grep, opts 'find grep')
vim.keymap.set('n', '<leader>fb', builtin.buffers, opts 'find buffer')
vim.keymap.set('n', '<leader>fh', builtin.help_tags, opts 'find help')

vim.keymap.set('n', '<leader>fG', function()
    local input_str = vim.fn.input('Search for regex >')
    if (input_str == '') then return end
    builtin.grep_string({
        search = input_str,
        use_regex = true
    })
end, opts 'find grep with search word')
-- Default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua#L135
