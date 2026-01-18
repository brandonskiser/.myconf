local M = {}

function M.default_lsp_keymaps(bufnr, client)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local function map(mode, l, r, opts)
        opts = opts or {}
        opts.silent = true
        opts.noremap = true
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
    end
    map('n', 'gD', vim.lsp.buf.declaration)
    map('n', 'gd', vim.lsp.buf.definition)
    if client and client.name == "rust_analyzer" then
        map('n', 'K', ':RustLsp hover actions<CR>')
    else
        map('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded' }) end)
    end
    map('n', 'gi', vim.lsp.buf.implementation)
    map('n', '<leader>s', vim.lsp.buf.signature_help)
    map('n', '<leader>wa', vim.lsp.buf.add_workspace_folder)
    map('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder)
    map('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end)
    map('n', '<leader>D', vim.lsp.buf.type_definition)
    map('n', '<leader>rn', vim.lsp.buf.rename)
    map('n', '<leader>ca', vim.lsp.buf.code_action)
    map('n', 'gr', vim.lsp.buf.references)
    map('n', '<leader>F', function() vim.lsp.buf.format { async = true } end)

    map('i', '<C-s>', vim.lsp.buf.signature_help)

    -- diagnostics
    map('n', '<leader>de', vim.diagnostic.open_float)
    map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true}) end)
    map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true}) end)
end

return M
