vim.pack.add({
    { src = gh("nvim-mini/mini.pick") },
    { src = gh("nvim-mini/mini.extra") }
})

require("mini.pick").setup({
    mappings = {
        mark = "<C-x>",
        mark_all = "<C-a>",
        choose_marked = "<C-e>",
        move_up = "<C-k>",
        move_down = "<C-j>",
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",
        toggle_info = "<C-i>",
        toggle_preview = "<C-p>",
        sys_paste = {
            char = "<C-v>",
            func = function()
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-r>+", true, true, true), "n", true)
            end,
        }
    }
})

require("mini.extra").setup()

vim.keymap.set("n", "<leader>ff", function()
    require("mini.pick").builtin.files(nil, {
        source = { cwd = require("oil").get_current_dir() }
    })
end, { noremap = true, desc = "find files" })

vim.keymap.set("n", "<leader>fh", function()
    require("mini.pick").builtin.help()
end, { noremap = true, desc = "find help tags" })

vim.keymap.set("n", "<leader>fg", function()
    require("mini.pick").builtin.grep_live(nil, {
        source = { cwd = require("oil").get_current_dir() }
    })
end, { noremap = true, desc = "live grep" })

vim.keymap.set("n", "<leader>fb", function()
    require("mini.extra").pickers.buf_lines({ scope = "current" })
end, { noremap = true, desc = "current buffer fuzzy find" })

vim.keymap.set("n", "<leader>fp", function()
    require("mini.pick").builtin.files(nil, {
        source = {
            name = 'Find plugin files',
            cwd = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'core', 'opt')
        }
    })
end, { noremap = true, desc = "find plugin files" })

vim.keymap.set("n", "<leader>fl", function()
    require("mini.extra").pickers.lsp()
end, { noremap = true, desc = "find lsp" })

vim.keymap.set("n", "<leader>ft", function()
    require("mini.extra").pickers.treesitter()
end, { noremap = true, desc = "find treesitter" })

vim.keymap.set("n", "<leader>fB", function()
    require("mini.extra").pickers.buf_lines()
end, { noremap = true, desc = "all buffers fuzzy find" })
