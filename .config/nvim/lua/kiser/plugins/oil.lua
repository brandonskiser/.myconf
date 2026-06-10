vim.pack.add({
    { src = gh("stevearc/oil.nvim") }
})
require("oil").setup()
vim.keymap.set("n", "\\", function()
    vim.cmd(":Oil")
end, { desc = "open in file explorer" })
