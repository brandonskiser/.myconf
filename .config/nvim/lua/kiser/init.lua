local function req(module)
    local ok, _ = pcall(require, module)
    if not ok then
        print('Module `' .. module .. '` unable to be imported.')
    end
end

local function packer_setup()
    req("kiser/defaults")
    req("kiser/keymaps")
    req("kiser/commands")

    req("kiser/packer")
    req("kiser/colorscheme")
    req("kiser/cmp")
    req("kiser/lsp")
    req("kiser/dap")
    req("kiser/treesitter")
    req("kiser/comment")
    req("kiser/autopairs")
    req("kiser/telescope")

    req("kiser/ztl")

    -- req("kiser/nvim-tree")
    -- req('kiser/neo-tree')
    req('kiser/oil')


    req("kiser/gitsigns")
    req("kiser/bufferline")
    req("kiser/lualine")
    req("kiser/which-key")

    req("kiser/buflist")
end

local function lazy_setup()
    req("kiser/defaults")
    req("kiser/keymaps")
    req("kiser/commands")
    req('kiser/buflist')

    -- req('kiser/lazy')
    require('kiser/lazy')
end

-- packer_setup()
lazy_setup()
