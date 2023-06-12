local util = require('kiser/lsp/util')
local rt = require('rust-tools')

rt.setup({
    server = util.make_opts {
        on_attach = function(_, bufnr)
            vim.keymap.set('n', '<leader>ha', rt.hover_actions.hover_actions, { buffer = bufnr })
            vim.keymap.set('n', '<leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
        end,
        settings = {
            ['rust-analyzer'] = {
                checkOnSave = {
                    command = 'clippy'
                }
            }
        }
    }
})

