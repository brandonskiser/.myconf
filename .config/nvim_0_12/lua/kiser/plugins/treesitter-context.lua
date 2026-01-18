vim.pack.add({
    { src = gh("nvim-treesitter/nvim-treesitter-context") }
})
require("treesitter-context").setup({ mode = 'cursor', max_lines = 4 })
