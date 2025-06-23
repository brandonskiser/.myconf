local function req(module)
    local ok, _ = pcall(require, module)
    if not ok then
        print('Module `' .. module .. '` unable to be imported.')
    end
end

local function lazy_setup()
    req('kiser.defaults')
    req('kiser.keymaps')
    req('kiser.commands')
    req('kiser.filetypes')
    req('kiser.buflist')

    -- All plugin stuff
    require('kiser.lazy')

    req('kiser.colorscheme')
end

lazy_setup()

-- enable all lsp servers under ~/.config/nvim/lsp/
local lsp_configs = {}

for _, fname in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
    -- :t - get tail of the file name
    -- :r - root of the file name (remove extension)
    local server_name = vim.fn.fnamemodify(fname, ':t:r')
    table.insert(lsp_configs, server_name)
end

vim.lsp.enable(lsp_configs)

