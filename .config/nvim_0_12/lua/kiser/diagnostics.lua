vim.keymap.set('n', '<leader>dt', function()
    local diagnostics = vim.diagnostic.get()
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
end, { noremap = true })

vim.keymap.set('n', '<leader>dT', function()
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
end, { noremap = true })

