return {
    {
        'L3MON4D3/LuaSnip',
        lazy = true, -- Loaded as a dependency of cmp
        dependencies = {
            "rafamadriz/friendly-snippets"
        }
    },

    {
        'famiu/bufdelete.nvim',
    },

    {
        'nvim-lualine/lualine.nvim',
        opts = {
            options = {
                theme = 'auto'
                -- theme = 'monokai-pro'
            }
        }
    },

    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        dependencies = { 'hrsh7th/nvim-cmp' },
        opts = function()
            -- If you want insert `(` after select function or method item
            local cmp_autopairs = require('nvim-autopairs.completion.cmp')
            local cmp = require('cmp')
            cmp.event:on(
                'confirm_done',
                cmp_autopairs.on_confirm_done()
            )
            return {}
        end
    },
    {
        'numToStr/Comment.nvim',
        dependencies = {
            'JoosepAlviste/nvim-ts-context-commentstring'
        },
        opts = function()
            local ts_context = require('ts_context_commentstring.integrations.comment_nvim')
            local opts = {
                pre_hook = ts_context.create_pre_hook(),
                -- LHS of toggle mappings in NORMAL mode
                toggler = {
                    -- Line-comment toggle keymap
                    line = '<leader>cc',
                    -- Block-comment toggle keymap
                    block = '<leader>Cc',
                },
                -- LHS of operator-pending mappings in NORMAL and VISUAL mode
                opleader = {
                    -- Line-comment keymap
                    line = '<leader>c',
                    -- Block-comment keymap
                    block = '<leader>C',
                },
                mappings = {
                    basic = true,
                    extra = true, -- extra key mappings (e.g., gco, gcO, gcA) don't use <leader>c prefix
                },
            }
            return opts
        end
    },

    {
        'folke/which-key.nvim',
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {},
        dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.icons' }, -- if you use standalone mini plugins
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' }, -- if you use the mini.nvim suite
        -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    },

    -- install with yarn or npm
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = "cd app && npm install",
        init = function()
            vim.g.mkdp_filetypes = { "markdown" }
        end,
        ft = { "markdown" },
    },
}
