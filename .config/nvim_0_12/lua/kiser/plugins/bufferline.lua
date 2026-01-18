vim.pack.add({
    { src = gh("akinsho/bufferline.nvim") }
})
require("bufferline").setup({
    options = {
        diagnostics = "nvim_lsp",
    }
})
vim.keymap.set("n", "<leader>bg", "<cmd>BufferLinePick<CR>", { desc = "go to buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "pick buffer to close" })
vim.keymap.set("n", "<S-Left>", "<cmd>BufferLineMovePrev<CR>", { desc = "move buffer left" })
vim.keymap.set("n", "<S-Right>", "<cmd>BufferLineMoveNext<CR>", { desc = "move buffer right" })
for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. tostring(i), "<cmd>BufferLineGoToBuffer " .. tostring(i) .. "<CR>")
end
