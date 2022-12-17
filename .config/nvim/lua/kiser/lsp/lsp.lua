-- setup order matters here - https://github.com/williamboman/mason-lspconfig.nvim#setup
require("mason").setup()
require("mason-lspconfig").setup({
    -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
    -- This setting has no relation with the `automatic_installation` setting.
    ensure_installed = {},

    -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
    -- This setting has no relation with the `ensure_installed` setting.
    -- Can either be:
    --   - false: Servers are not automatically installed.
    --   - true: All servers set up via lspconfig are automatically installed.
    --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
    --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
    automatic_installation = true,
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()


local function lsp_highlight_document(client)
    if client.server_capabilities.document_highlight then
        vim.api.nvim_exec(
            [[
                augroup lsp_document_highlight
                    autocmd! * <buffer>
                    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                augroup END
            ]],
            false
        )
    end
end

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

-- Display diagnostics on change, instead of only on buffer write.
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        update_in_insert = true,
    }
)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function lsp_keymaps(bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<leader>s', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>D', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', '<leader>F', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local function on_attach(client, bufnr)
    lsp_keymaps(bufnr)
    lsp_highlight_document(client)
end

local lsp_flags = {
    -- This is the default in Nvim 0.7+
    debounce_text_changes = 150,
}

local default_opts = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = on_attach,
    flags = lsp_flags
}

-- Wrap the passed in opts to also enable the default_opts above.
local function make_opts(opts)
    local wrapper_on_attach = function(c, b)
        if opts.on_attach then
            opts.on_attach(c, b)
        end
        default_opts.on_attach(c, b)
    end
    return {
        on_attach = wrapper_on_attach,
        capabilities = default_opts.capabilities,
        flags = default_opts.lsp_flags,
    }
end

-- lspconfig to mason.nvim package name mapping: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
-- Have to use the lspconfig name for setup.
local lspconfig = require("lspconfig")

lspconfig.pyright.setup(default_opts)

-- lspconfig.rust_analyzer.setup(opts)
-- local rt = require("rust-tools")
-- require("rust-tools").setup {
--     server = default_opts
-- }
local rt = require("rust-tools")
rt.setup({
    server = make_opts {
        on_attach = function(_, bufnr)
            vim.keymap.set('n', '<leader>ha', rt.hover_actions.hover_actions, { buffer = bufnr })
            vim.keymap.set('n', '<leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
        end
    }
})

local jsonls_opts = require("kiser/lsp/settings/jsonls")
lspconfig.jsonls.setup(vim.tbl_deep_extend("force", jsonls_opts, default_opts))

-- lspconfig.clangd.setup(opts)
local clangd_opts = require("kiser/lsp/settings/clangd_extensions")
require("clangd_extensions").setup {
    server = default_opts,
    extensions = clangd_opts.extensions
}

local sumneko_lua_opts = require("kiser/lsp/settings/sumneko_lua")
-- lspconfig.sumneko_lua.setup(sumneko_lua_opts)
lspconfig.sumneko_lua.setup(vim.tbl_deep_extend("force", sumneko_lua_opts, default_opts))
