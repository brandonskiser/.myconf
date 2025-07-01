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

local function setup_lsp()
    local home_dir = os.getenv('HOME')
    if not home_dir then return end

    -- enable all lsp servers under ~/.config/nvim/lsp/
    -- local local_lsp_dir = require('kiser.util.path').join(home_dir, '.config', 'nvim', 'lsp')
    local local_lsp_dir = require('kiser.util.path').join(vim.fn.stdpath('config'), 'lsp')

    local lsp_configs = {}
    for _, fpath in pairs(vim.api.nvim_get_runtime_file('lsp/*.lua', true)) do
        if fpath:match(local_lsp_dir) then
            -- :t - get tail of the file name
            -- :r - root of the file name (remove extension)
            local server_name = vim.fn.fnamemodify(fpath, ':t:r')
            table.insert(lsp_configs, server_name)
        end
    end
    vim.lsp.enable(lsp_configs)


    vim.api.nvim_create_autocmd('LspAttach', {
        --- @param ev vim.api.keyset.create_autocmd.callback_args
        callback = function(ev)
            require('kiser.plugins.lsp.util').default_lsp_keymaps(ev.buf)
        end
    })
end

setup_lsp()

