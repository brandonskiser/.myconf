vim.pack.add({
    { src = gh("lewis6991/gitsigns.nvim") }
})
if vim.fs.root(vim.env.PWD, ".git") ~= nil then
    require("gitsigns").setup()
end
