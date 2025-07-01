local M = {}

local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

local function lsp_highlight_document(client)
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec2(
            [[
                augroup lsp_document_highlight
                    autocmd! * <buffer>
                    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                augroup END
            ]],
            {}
        )
    end
end

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
function M.default_lsp_keymaps(bufnr)
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
    map('n', 'K', function() vim.lsp.buf.hover({ border = 'rounded' }) end)
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
end

local function on_attach(client, bufnr)
    M.default_lsp_keymaps(bufnr)
    lsp_highlight_document(client)
end

M.default_opts = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = on_attach,
    flags = lsp_flags
}

-- Wrap the passed in opts to also enable the default_opts above.
function M.make_opts(opts)
    local wrapper_on_attach = function(c, b)
        M.default_opts.on_attach(c, b)
        if opts.on_attach then
            opts.on_attach(c, b)
        end
    end
    return vim.tbl_deep_extend("keep", {
        on_attach = wrapper_on_attach,
        capabilities = M.default_opts.capabilities,
        flags = M.default_opts.lsp_flags,
    }, opts)
end

return M


