local util = require('kiser.ztl.util')

if not util.in_wiki() then
    vim.notify('Not in wiki')
    return
end

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local action_state = require 'telescope.actions.state'
local actions = require 'telescope.actions'
local themes = require 'telescope.themes'

local put_tag = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = 'Tags',
        finder = finders.new_oneshot_job({ 'cat', util.tagslist_index_fname }, opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if not selection then return end
                vim.api.nvim_put({ '#' .. selection[1] .. ' ' }, '', true, true)
            end)
            return true
        end
    }):find()
end

local put_link = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = 'Zettels',
        finder = finders.new_oneshot_job({ 'cat', util.tags_index_fname }, opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if not selection then return end
                local j = selection[1]:find(' ')
                local id = selection[1]:sub(1, j - 4)
                vim.api.nvim_put({ '[[' .. id .. ']]' }, '', true, true)
            end)
            return true
        end
    }):find()
end

local find_in_tags_index = function(opts)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = 'Find in tags index',
        finder = finders.new_oneshot_job({ 'cat', util.tags_index_fname }, opts),
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if not selection then return end
                selection = selection[1]
                local j = selection:find(' ')
                local id = selection:sub(1, j - 1)
                local fname = util.ztl_dirname .. id
                vim.cmd(':e ' .. fname)
            end)
            return true
        end
    }):find()
end

vim.api.nvim_create_user_command('ZtlFind', function()
    find_in_tags_index({})
end, {})

vim.api.nvim_create_user_command('ZtlPutTag', function()
    put_tag(themes.get_cursor {})
end, {})

vim.api.nvim_create_user_command('ZtlPutLink', function()
    put_link(themes.get_cursor {})
end, {})

local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>npt', ':ZtlPutTag<CR>', keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>npl', ':ZtlPutLink<CR>', keymap_opts)
vim.api.nvim_set_keymap('n', '<leader>nf', ':ZtlFind<CR>', keymap_opts)
