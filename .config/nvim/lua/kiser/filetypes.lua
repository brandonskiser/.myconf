vim.filetype.add({
    extension = {
        wgsl = 'wgsl'
    }
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'html',
    callback = function(opts)
        vim.api.nvim_buf_set_option(opts.buf, 'tabstop', 2)
        vim.api.nvim_buf_set_option(opts.buf, 'shiftwidth', 2)
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescript', 'typescriptreact' },
    callback = function(opts)
        vim.api.nvim_buf_set_option(opts.buf, 'tabstop', 2)
        vim.api.nvim_buf_set_option(opts.buf, 'shiftwidth', 2)
    end
})
