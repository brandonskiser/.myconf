if vim.fs.root(vim.env.PWD, ".git") then
    vim.pack.add({ gh("sindrets/diffview.nvim") })
end
