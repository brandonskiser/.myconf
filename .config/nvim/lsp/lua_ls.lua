local function neovim_settings()
    return {
        runtime = {
            version = "LuaJIT",
            path = {
                "lua/?.lua",
                "lua/?/init.lua",
            },
        },
        workspace = {
            checkThirdParty = false,
            library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
            },
        },
    }
end

--- @type vim.lsp.Config
return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_dir = function(bufnr, on_dir)
        local filename = vim.api.nvim_buf_get_name(bufnr)
        local config_root = vim.fn.stdpath("config")
        if vim.startswith(filename, config_root .. "/") then
            on_dir(config_root)
            return
        end

        local root = vim.fs.root(bufnr, { ".luarc.json", ".luarc.jsonc", ".git" })
        if root then
            on_dir(root)
        end
    end,
    before_init = function(_, config)
        local root = config.root_dir
        if
            root ~= vim.fn.stdpath("config")
            and root
            and (vim.uv.fs_stat(root .. "/.luarc.json") or vim.uv.fs_stat(root .. "/.luarc.jsonc"))
        then
            return
        end

        config.settings.Lua = vim.tbl_deep_extend("force", config.settings.Lua, neovim_settings())
    end,
    settings = {
        Lua = {
            workspace = {
                checkThirdParty = false,
            },
            telemetry = {
                enable = false,
            },
        },
    },
}
