return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            { "folke/neodev.nvim", opts = {} },
        },
        config = function(_, _)
            local util = require('kiser.plugins.lsp.util')
            require('mason').setup()

            -- Global mappings for diagnostics,
            local opts = { noremap = true, silent = true }
            vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, opts)
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

            -- Display diagnostics on change, instead of only on buffer write.
            vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
                vim.lsp.diagnostic.on_publish_diagnostics,
                { update_in_insert = true }
            )

            vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
                vim.lsp.handlers.hover,
                { border = 'rounded' }
            )

            -- For servers without extra plugin requirements, we can just
            -- iterate through them and run setup on each.
            local servers = require('kiser/plugins/lsp/servers')
            for server, server_opts in pairs(servers) do
                require('lspconfig')[server].setup(util.make_opts(server_opts))
            end
        end
    },

    {
        'williamboman/mason-lspconfig.nvim',
        dependencies = {
            -- Setup order matters here. mason.nvim should be setup before mason=lspconfig.nvim
            -- https://github.com/williamboman/mason-lspconfig.nvim#setup
            'williamboman/mason.nvim'
        },
        opts = {
            -- A list of servers to automatically install if they're not already installed. Example: { "rust_analyzer@nightly", "sumneko_lua" }
            -- This setting has no relation with the `automatic_installation` setting.
            ensure_installed = {},

            -- Whether servers that are set up (via lspconfig) should be automatically installed if they're not already installed.
            -- This setting has no relation with the `ensure_installed` setting.
            -- Can either be:
            --   - false: Servers are not automatically installed.
            --   - true: All servers set up via lspconfig are automatically installed.
            --   - { exclude: string[] }: All servers set up via lspconfig, except the ones provided in the list, are automatically installed.
            --       Example: automatic_installation = { exclude = { "rust_analyzer", "solargraph" } }
            automatic_installation = true,
        }
    },

    {
        'folke/lsp-colors.nvim',
        opts = {
            Error = "#db4b4b",
            Warning = "#e0af68",
            Information = "#0db9d7",
            Hint = "#10B981"
        }
    },

    {
        'simrat39/rust-tools.nvim',
        ft = 'rust',
        dependencies = {
            'neovim/nvim-lspconfig',
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
        },
        opts = function()
            local util = require('kiser.plugins.lsp.util')
            local rt = require('rust-tools')
            local opts = {
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
                                allTargets = true -- Setting to false fixes issue with no_std crates panic_handler conflicting definitions.
                            },
                            rustfmt = {
                                extraArgs = { '+nightly' }
                            },
                        }
                    }
                }
            }
            return opts
        end
    },

    -- Setup jsonls server
    {
        'b0o/schemastore.nvim',
        ft = { 'json', 'jsonc' },
        dependencies = {
            'neovim/nvim-lspconfig'
        },
        config = function()
            local schemas = require("schemastore").json.schemas()
            local util = require('kiser.plugins.lsp.util')
            local jsonls_opts = {
                settings = {
                    json = {
                        schemas = schemas,
                        validate = { enable = true },
                    }
                },
            }
            require("lspconfig").jsonls.setup(util.make_opts(jsonls_opts))
        end
    },

    {
        'mfussenegger/nvim-jdtls',
        ft = { 'java' },
        dependencies = {
            'neovim/nvim-lspconfig',
        },
        config = function()
            local jdtls_config = require('kiser.plugins.lsp.jdtls').jdtls_config
            require('jdtls').start_or_attach(jdtls_config)
        end
    }
}

