vim.lsp.enable({
    "clangd",
    "gopls",
    "gdscript",
    "html",
    "lua_ls",
    "luau_lsp",
    "pyright",
    "typescript",
    "wgsl_analyzer",
})

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        require("kiser.util.lsp").default_lsp_keymaps(ev.buf, client)
    end
})

vim.api.nvim_create_user_command('LspInfo', ':checkhealth vim.lsp', { desc = 'Alias to `:checkhealth vim.lsp`' })

vim.api.nvim_create_user_command('LspLog', function()
    vim.cmd(string.format('tabnew %s', vim.lsp.log.get_filename()))
end, { desc = 'Opens the Nvim LSP client log.' })

vim.api.nvim_create_user_command('LspRestart', function(input)
    vim.api.nvim_cmd({
        cmd = 'lsp',
        args = vim.list_extend({ 'restart' }, input.fargs),
    }, {})
end, {
    nargs = '*',
    desc = 'Restart LSP clients attached to the current buffer, or named clients',
})

vim.api.nvim_create_user_command('LspStop', function()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    for _, client in ipairs(clients) do
        client:stop()
    end
end, { desc = 'Stop LSP clients attached to the current buf' })
