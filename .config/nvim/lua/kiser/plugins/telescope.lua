local _Pickers_cached = nil
local Pickers = function()
    if _Pickers_cached ~= nil then
        return _Pickers_cached
    end
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

    -- why is this broken :(
    -- https://www.youtube.com/watch?v=xdXE1tOT-qg
    function M.live_multigrep(opts)
        opts = opts or {}
        opts.cwd = opts.cwd or vim.uv.cwd()

        pickers
            .new(opts, {
                prompt_title = "Live Multigrep",
                debounce = 100,
                finder = finders.new_async_job({
                    command_generator = function(prompt)
                        if not prompt or prompt == "" then
                            return nil
                        end

                        local pieces = vim.split(prompt, "  ")
                        local args = { "rg" }
                        if pieces[1] then
                            table.insert(args, "-e")
                            table.insert(args, pieces[1])
                        end

                        if pieces[2] then
                            table.insert(args, "-g")
                            table.insert(args, pieces[2])
                        end
                        ---@diagnostic disable-next-line: deprecated
                        return vim.tbl_flatten(
                            args,
                            { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column",
                                "--smart-case" }
                        )
                    end,
                    entry_maker = make_entry.gen_from_vimgrep(opts),
                    -- this entry maker is broken for some reason
                    -- entry_maker = function(entry)
                    --     local s = vim.inspect(entry)
                    --     print('Got entry: ' .. s)
                    --     print('Opts' .. vim.inspect(opts))
                    --     local r = make_entry.gen_from_vimgrep(opts)(entry)
                    --     print('Returning entry: ' .. vim.inspect(r))
                    --     return r
                    -- end,
                    cwd = opts.cwd,
                }),
                previewer = conf.grep_previewer(opts),
                sorter = require("telescope.sorters").empty(),
            })
            :find()
    end

    _Pickers_cached = M
    return M
end

return {
    {
        'nvim-telescope/telescope.nvim',
        cmd = 'Telescope',
        version = false, -- telescope did only one release, so use HEAD for now
        dependencies = {
            'nvim-lua/plenary.nvim',
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                lazy = true,
                build = "make",
                enabled = vim.fn.executable("make") == 1,
                dependencies = { { 'nvim-telescope/telescope.nvim' } },
                config = function()
                    require("telescope").load_extension("fzf")
                end
            }
        },
        init = function()
            -- show line numbers in file preview
            vim.cmd "autocmd User TelescopePreviewerLoaded setlocal number"
        end,
        opts = function()
            local layout_actions = require('telescope.actions.layout')
            local opts = {
                defaults = {
                    mappings = {
                        i = {
                            ["<C-p>"] = layout_actions.toggle_preview
                        },
                        n = {
                            ["<C-p>"] = layout_actions.toggle_preview
                        }
                    }
                },
                pickers = {
                    -- Configure defaults for builtins here.
                    find_files = {
                        -- previewer = true,
                    }
                },
                extensions = {
                    fzf = {
                        fuzzy = true,                   -- false will only do exact matching
                        override_generic_sorter = true, -- override the generic sorter
                        override_file_sorter = true,    -- override the file sorter
                        case_mode = "smart_case"        -- or "ignore_case" or "respect_case"
                        -- the default case_mode is "smart_case"
                    }
                }
            }
            return opts
        end,
        keys = function()
            local builtin = require("telescope.builtin")
            return {
                { '<leader>ff', builtin.find_files,                  desc = 'find files' },
                { '<leader>fg', builtin.live_grep,                   desc = 'live grep' },
                -- { '<leader>fg', Pickers().live_multigrep,            desc = 'live grep' },
                { '<leader>fh', builtin.help_tags,                   desc = 'find help' },
                { '<leader>gf', builtin.git_files,                   desc = 'git files' },
                { '<leader>fb', Pickers().current_buffer_fuzzy_find, desc = 'find in buffer' },
                {
                    '<leader>fG',
                    function()
                        local input_str = vim.fn.input('Search for regex >')
                        if (input_str == '') then return end
                        builtin.grep_string({
                            search = input_str,
                            use_regex = true
                        })
                    end,
                    desc = 'find grep with search word'
                },
                {
                    '<leader>fp',
                    function()
                        builtin.find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath('data'), 'lazy') })
                    end,
                    desc = 'find file in a plugin'
                }
            }
        end
    }
}
