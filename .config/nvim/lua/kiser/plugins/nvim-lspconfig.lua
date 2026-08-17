vim.pack.add({
    { src = gh("neovim/nvim-lspconfig") }
})

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

-- local function luau_definitions(root_dir)
--     local candidates = {
--         root_dir and vim.fs.joinpath(root_dir, "lua/meta/kiro.d.luau"),
--         vim.fn.expand("~/.kiro/cli/data/lua/meta/kiro.d.luau"),
--     }
--     for _, path in ipairs(candidates) do
--         if path and vim.uv.fs_stat(path) then
--             return path
--         end
--     end
--     return nil
-- end
--
-- vim.lsp.config("luau_lsp", {
--     cmd = function(dispatchers, config)
--         local cmd = { "luau-lsp", "lsp" }
--         local defs = luau_definitions(config.root_dir)
--         if defs then
--             table.insert(cmd, "--definitions=" .. defs)
--         end
--         return vim.lsp.rpc.start(cmd, dispatchers, { cwd = config.root_dir })
--     end,
--     -- Root at the nearest .luaurc so alias config is inside the
--     -- workspace (~/.kiro/cli for user config, repo root otherwise).
--     root_markers = { ".luaurc", ".git" },
-- })

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

vim.api.nvim_create_user_command('LspStop', function()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    for _, client in ipairs(clients) do
        client:stop()
    end
end, { desc = 'Stop LSP clients attached to the current buf' })
