vim.pack.add({
    { src = gh("neovim/nvim-lspconfig") }
})

local home_dir = os.getenv("HOME")
if not home_dir then return end

local local_lsp_dir = require("kiser.util.path").join(vim.fn.stdpath("config"), "lsp")
local lsp_configs = {}
for _, fpath in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
    if fpath:match(local_lsp_dir) then
        local server_name = vim.fn.fnamemodify(fpath, ":t:r")
        table.insert(lsp_configs, server_name)
    end
end
vim.lsp.enable(lsp_configs)

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
