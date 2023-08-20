local util = require('kiser/lsp/util')
local rt = require('rust-tools')

rt.setup({
    server = util.make_opts {
        on_attach = function(_, bufnr)
            vim.keymap.set('n', '<leader>ha', rt.hover_actions.hover_actions, { buffer = bufnr })
            vim.keymap.set('n', '<leader>a', rt.code_action_group.code_action_group, { buffer = bufnr })
        end,

        -- These override the defaults set by rust-tools.nvim
        -- See https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#rust_analyzer
        settings = {
            ['rust-analyzer'] = {
                -- rust-analyzer settings: https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
                -- rust-tools mapping:     https://github.com/simrat39/rust-tools.nvim/blob/master/ci/schema/output.md
                checkOnSave = {
                    command = 'clippy',
                    allTargets = false    -- Fixes issue with no_std crates panic_handler conflicting definitions.
                },
            }
        }
    }
})

