local util = require("kiser/lsp/util")

-- Must setup neodev before lspconfig.
require("neodev").setup {}

local lua_ls_opts = {
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" }
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                library = vim.api.nvim_get_runtime_file("", true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    }
}

require("lspconfig").lua_ls.setup(vim.tbl_deep_extend("force", lua_ls_opts, util.default_opts))

