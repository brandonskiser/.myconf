local util = require("kiser/lsp/util")

require('neodev').setup
    {
        library = {
            enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
            -- these settings will be used for your Neovim config directory
            runtime = true, -- runtime path
            types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
            plugins = true, -- installed opt or start plugins in packpath
            -- you can also specify the list of plugins to make available as a workspace library
            -- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
        },
        setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
        -- for your Neovim config directory, the config.library settings will be used as is
        -- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
        -- for any other directory, config.library.enabled will be set to false
        override = function(root_dir, options) end,
        -- With lspconfig, Neodev will automatically setup your lua-language-server
        -- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
        -- in your lsp start options
        lspconfig = true,
        -- much faster, but needs a recent built of lua-language-server
        -- needs lua-language-server >= 3.6.0
        pathStrict = false,
    }


local lua_ls_opts = {
    settings = {
        Lua = {
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
                enable = false,
            },
        },
    },
    -- on_init = function(client)
    --     local path = client.workspace_folders[1].name
    --     if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
    --         client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
    --             Lua = {
    --                 runtime = {
    --                     -- Tell the language server which version of Lua you're using
    --                     -- (most likely LuaJIT in the case of Neovim)
    --                     version = 'LuaJIT'
    --                 },
    --                 -- Make the server aware of Neovim runtime files
    --                 workspace = {
    --                     checkThirdParty = false,
    --                     library = {
    --                         vim.env.VIMRUNTIME
    --                         -- "${3rd}/luv/library"
    --                         -- "${3rd}/busted/library",
    --                     }
    --                     -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
    --                     -- library = vim.api.nvim_get_runtime_file("", true)
    --                 }
    --             }
    --         })
    --
    --         client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    --     end
    --     return true
    -- end
}

require("lspconfig").lua_ls.setup(vim.tbl_deep_extend("force", lua_ls_opts, util.default_opts))
