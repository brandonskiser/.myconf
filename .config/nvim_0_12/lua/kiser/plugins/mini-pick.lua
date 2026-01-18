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
        toggle_preview = "<C-p>"
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
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local lines_with_numbers = {}
    for lnum, line in ipairs(lines) do
        lines_with_numbers[#lines_with_numbers + 1] = lnum .. " | " .. line
    end
    local selected_line = require("mini.pick").start({
        source = { name = "Buffer lines", items = lines_with_numbers }
    })
    if selected_line == nil then return end
    local idx = selected_line:find(" |")
    if idx == nil then return end
    local line_num = tonumber(selected_line:sub(1, idx - 1))
    vim.api.nvim_win_set_cursor(0, { line_num, 0 })
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
