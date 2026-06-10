vim.pack.add({
    { src = gh("OXY2DEV/markview.nvim") }
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function(opts)
        vim.keymap.set('n', '<C-m>', ':Markview<CR>', { noremap = true, buffer = opts.buf })
    end
})
