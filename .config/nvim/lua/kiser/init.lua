local function req(module)
    local ok, _ = pcall(require, module)
    if not ok then
        print('Module `' .. module .. '` unable to be imported.')
    end
end

req("kiser/defaults")
req("kiser/keymaps")
req("kiser/commands")
req("kiser/plugins")
req("kiser/colorscheme")
req("kiser/cmp")
req("kiser/lsp")
req("kiser/dap")
req("kiser/treesitter")
req("kiser/comment")
req("kiser/autopairs")
req("kiser/telescope")

-- req("kiser/nvim-tree")
-- req('kiser/neo-tree')
req('kiser/oil')


req("kiser/gitsigns")
req("kiser/bufferline")
req("kiser/lualine")
req("kiser/which-key")

