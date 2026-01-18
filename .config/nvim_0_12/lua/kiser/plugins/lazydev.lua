vim.pack.add({
    { src = gh("folke/lazydev.nvim") }
})
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'lua',
    callback = function()
        require('lazydev').setup()
    end
})
