vim.pack.add({
    { src = gh("stevearc/aerial.nvim") }
})
require("aerial").setup()
vim.api.nvim_set_keymap("n", "<leader>at", "<cmd>AerialToggle!<CR>", { desc = "toggle aerial" })
vim.keymap.set("n", "<leader>fa", function()
    require("kiser.mini-aerial").pick()
end, { noremap = true, desc = "find current buffer symbols" })
