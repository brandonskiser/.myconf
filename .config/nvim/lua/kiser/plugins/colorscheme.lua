return {
    {
        "scottmckendry/cyberdream.nvim",
        enabled = true,
        lazy = false,
        priority = 1000,
        opts = {
            transparent = true,
        },
    },

    {
        "echasnovski/mini.base16",
        enabled = true,
        version = false,
        priority = 1000,
    },

    {
        "RRethy/base16-nvim",
        -- enabled = false,
        config = function()
            -- Including this purely for the color schemes.
            -- Enabling it seems to cause issues with :LualineNotices for some reason.
        end
    },

    {
        'loctvl842/monokai-pro.nvim',
        enabled = false,
        -- enabled = true,
        priority = 500, -- default is 50, so prioritize loading this first
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
    },
}
