vim.filetype.add({
    extension = {
        wgsl = 'wgsl'
    },
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'html',
    callback = function(opts)
        vim.api.nvim_set_option_value('tabstop', 2, { buf = opts.buf })
        vim.api.nvim_set_option_value('shiftwidth', 2, { buf = opts.buf })
    end
})

vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'typescript', 'typescriptreact' },
    callback = function(opts)
        vim.api.nvim_set_option_value('tabstop', 2, { buf = opts.buf })
        vim.api.nvim_set_option_value('shiftwidth', 2, { buf = opts.buf })
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

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'gitconfig',
    callback = function(ev)
        vim.api.nvim_set_option_value('expandtab', false, { buf = ev.buf })
    end,
})

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
    callback = function(ev)
        -- Override markview setting the conceallevel to 3
        -- how to check who set conceallevel: `:verbose setlocal conceallevel?`
        if vim.bo[ev.buf].filetype == 'json' then
            vim.opt_local.conceallevel = 0
        end
    end,
})
