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

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function(ev)
        vim.api.nvim_buf_create_user_command(ev.buf, 'Mdview', function()
            vim.fn.jobstart({ vim.fn.expand('~/.bin/mdview'), vim.api.nvim_buf_get_name(0) }, { detach = true })
        end, {})
        vim.keymap.set('n', '<leader>m', '<cmd>Mdview<CR>', { buffer = ev.buf })
    end,
})
