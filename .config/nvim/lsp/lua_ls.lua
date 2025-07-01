local plugin_workspace_folders_added = false

--- @type vim.lsp.Config
return {
    root_dir = function(bufnr, cb)
        -- If we are in the neovim config, then set the root as the neovim config.
        local fname = vim.api.nvim_buf_get_name(bufnr)
        if fname:match(vim.fn.stdpath("config")) then
            return cb(vim.fn.stdpath("config"))
        end
    end,

    on_attach = function(client, bufnr)
        local path = require("kiser.util.path")

        -- If we are in the neovim config, then add all of the plugins as workspace folders.
        -- idk how to do this, think I just need to depend on lazydev unfortunately
        -- if client.root_dir:match(vim.fn.stdpath('config'))
        --     and not plugin_workspace_folders_added
        -- then
        --     local lazy_path = path.join(vim.fn.stdpath('data'), 'lazy')
        --     local handle = vim.uv.fs_opendir(lazy_path, nil, 99)
        --     local entries = vim.uv.fs_readdir(handle)
        --     for _, entry in ipairs(entries) do
        --         if entry.type == 'directory' then
        --             local yee = path.join(lazy_path, entry.name)
        --             vim.lsp.buf.add_workspace_folder(yee)
        --         end
        --     end
        --     plugin_workspace_folders_added = true
        -- end
    end,

    on_init = function(client)
        if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
                path ~= vim.fn.stdpath("config")
                and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
            then
                return
            end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
            runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                    "lua/?.lua",
                    "lua/?/init.lua",
                },
            },
            -- Make the server aware of Neovim runtime files
            workspace = {
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                    -- Depending on the usage, you might want to add additional paths
                    -- here.
                    "${3rd}/luv/library",
                    -- '${3rd}/busted/library'
                }
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
            }
        })
    end,

    settings = {
        Lua = {
            workspace = {
                checkThirdParty = false,
                -- library = { '/home/brandon/.config/nvim/' }
            },
            telemetry = {
                enable = false,
            },

        }
    }
}
