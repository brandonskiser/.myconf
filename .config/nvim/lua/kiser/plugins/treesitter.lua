return {
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            local configs = require('nvim-treesitter.configs')
            configs.setup {
                -- Supported languages: https://github.com/nvim-treesitter/nvim-treesitter#supported-languages
                -- A list of parser names, or "all"
                ensure_installed = { "c", "rust", "toml", "json" },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
                auto_install = true,

                -- List of parsers to ignore installing (for "all")
                -- ignore_install = { "javascript" },

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,

                    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
                    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
                    -- the name of the parser)
                    -- list of language that will be disabled
                    -- disable = { "c", "rust" },
                    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
                    -- disable = function(lang, buf)
                    --     local max_filesize = 100 * 1024 -- 100 KB
                    --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    --     if ok and stats and stats.size > max_filesize then
                    --         return true
                    --     end
                    -- end,

                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
                    -- Using this option may slow down your editor, and you may see some duplicate highlights.
                    -- Instead of true it can also be a list of languages
                    additional_vim_regex_highlighting = false,
                },

                rainbow = {
                    enable = false,
                    -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
                    extended_mode = true,     -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
                    max_file_lines = nil,     -- Do not enable for files with more than n lines, int
                    -- colors = {},              -- table of hex strings
                    -- termcolors = {}           -- table of colour name strings
                },
            }
        end
    },

    {
        'nvim-treesitter/nvim-treesitter-context',
        event = 'VeryLazy',
        opts = { mode = 'cursor', max_lines = 4 },
    },

    {
        'stevearc/aerial.nvim',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
            'nvim-tree/nvim-web-devicons',
            'nvim-telescope/telescope.nvim'
        },
        init = function()
            vim.api.nvim_create_user_command('FindSymbols', function()
                vim.cmd('Lazy load telescope.nvim')
                require('telescope').extensions.aerial.aerial()
            end, {})
        end,
        opts = function()
            local telescope = require('telescope')
            telescope.load_extension('aerial')
            return {}
        end,
        cmd = { 'AerialOpen', 'AerialToggle' },
        keys = {
            { '<leader>at', '<cmd>AerialToggle!<CR>', desc = 'toggle aerial' },
            { '<leader>fa', '<cmd>FindSymbols<CR>', desc = 'find symbol' }
        },
    }
}
