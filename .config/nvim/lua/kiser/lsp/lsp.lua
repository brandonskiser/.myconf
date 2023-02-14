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

-- lspconfig to mason.nvim package name mapping: https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
-- Have to use the lspconfig name for setup.

require("kiser/lsp/servers/pyright")

require("kiser/lsp/servers/rust-tools")

require("kiser/lsp/servers/jsonls")

require("kiser/lsp/servers/clangd_extensions")

require("kiser/lsp/servers/lua_ls")

require("kiser/lsp/servers/jdtls")

