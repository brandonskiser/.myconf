return {
    {
        "scottmckendry/cyberdream.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            transparent = true,
        }
    },
    {
        'loctvl842/monokai-pro.nvim',
        priority = 500, -- default is 50, so prioritize loading this first
        enabled = true,
        opts = {
            transparent_background = false,
            terminal_colors = true,
            devicons = true, -- highlight the icons of `nvim-web-devicons`
            styles = {
                comment = { italic = true },
                keyword = { italic = true },       -- any other keyword
                type = { italic = true },          -- (preferred) int, long, char, etc
                storageclass = { italic = true },  -- static, register, volatile, etc
                structure = { italic = true },     -- struct, union, enum, etc
                parameter = { italic = true },     -- parameter pass in function
                annotation = { italic = true },
                tag_attribute = { italic = true }, -- attribute of tag in reactjs
            },
            -- filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
            filter = "octagon",
            -- Enable this will disable filter option
            day_night = {
                enable = false,            -- turn off by default
                day_filter = "pro",        -- classic | octagon | pro | machine | ristretto | spectrum
                night_filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
            },
            inc_search = "background",     -- underline | background
            background_clear = {
                -- "float_win",
                "toggleterm",
                "telescope",
                "which-key",
                "renamer",
                -- "neo-tree"
            }, -- "float_win", "toggleterm", "telescope", "which-key", "renamer", "neo-tree"
            plugins = {
                bufferline = {
                    underline_selected = false,
                    underline_visible = false,
                },
                indent_blankline = {
                    context_highlight = "default", -- default | pro
                    context_start_underline = false,
                },
            },
            ---@param c Colorscheme
            override = function(c) end,
        },
        config = function(_, opts)
            require('monokai-pro').setup(opts)
            vim.cmd('colorscheme monokai-pro')
        end
    }
}
