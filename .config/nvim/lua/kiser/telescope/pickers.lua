local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local action_state = require 'telescope.actions.state'
local action_set = require 'telescope.actions.set'
local actions = require 'telescope.actions'
local make_entry = require 'telescope.make_entry'
local themes = require 'telescope.themes'

local M = {}

function M.current_buffer_fuzzy_find(opts)
    opts = opts or { bufnr = vim.api.nvim_get_current_buf() }
    -- All actions are on the current buffer
    local filename = vim.fn.expand(vim.api.nvim_buf_get_name(opts.bufnr))

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    local lines_with_numbers = {}

    for lnum, line in ipairs(lines) do
        table.insert(lines_with_numbers, {
            lnum = lnum,
            bufnr = opts.bufnr,
            filename = filename,
            text = line,
        })
    end

    pickers
        .new(opts, {
            prompt_title = "Current Buffer Fuzzy",
            finder = finders.new_table {
                results = lines_with_numbers,
                entry_maker = opts.entry_maker or make_entry.gen_from_buffer_lines(opts),
            },
            sorter = conf.generic_sorter(opts),
            previewer = conf.grep_previewer(opts),
            attach_mappings = function()
                action_set.select:enhance {
                    post = function()
                        local selection = action_state.get_selected_entry()
                        vim.api.nvim_win_set_cursor(0, { selection.lnum, 0 })
                    end,
                }

                return true
            end,
        })
        :find()
end

return M
