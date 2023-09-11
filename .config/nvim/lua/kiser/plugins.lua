-- Automatically install and set up packer.nvim
-- https://github.com/wbthomason/packer.nvim#usage
local ensure_packer = function()
    local fn = vim.fn
    -- data directory in .local/share/nvim
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

local packer_bootstrap = ensure_packer()
local ok, packer = pcall(require, "packer")
if not ok then
    print("Failed to require packer")
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end
    }
}

return packer.startup(function(use)
    use 'wbthomason/packer.nvim' -- Have packer manage itself

    -- My plugins here
    use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim" -- Useful lua functions used by lots of plugins, e.g. telescope
    use "numToStr/Comment.nvim" -- Easily comment stuff
    use "windwp/nvim-autopairs" -- https://github.com/windwp/nvim-autopairs
    use {
        'akinsho/bufferline.nvim', -- https://github.com/akinsho/bufferline.nvim
        tag = "v3.*",
        requires = 'nvim-tree/nvim-web-devicons'
    }
    use 'famiu/bufdelete.nvim' -- https://github.com/famiu/bufdelete.nvim
    use {
        'nvim-lualine/lualine.nvim', -- https://github.com/nvim-lualine/lualine.nvim
        requires = {
            'kyazdani42/nvim-web-devicons', opt = true
        }
    }
    use { "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" } -- https://github.com/folke/trouble.nvim
    use 'folke/lsp-colors.nvim' -- https://github.com/folke/lsp-colors.nvim
    use "folke/which-key.nvim" -- https://github.com/folke/which-key.nvim
    -- https://github.com/iamcco/markdown-preview.nvim
    use({ "iamcco/markdown-preview.nvim", run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end, ft = { "markdown" }, })
    use 'NoahTheDuke/vim-just'

    -- Color schemes
    -- https://github.com/rockerBOO/awesome-neovim#tree-sitter-supported-colorscheme
    use "sainnhe/sonokai" -- https://github.com/sainnhe/sonokai
    use "ellisonleao/gruvbox.nvim" -- https://github.com/ellisonleao/gruvbox.nvim
    use { "catppuccin/nvim", as = "catppuccin" } -- https://github.com/catppuccin/nvim
    use 'navarasu/onedark.nvim' -- https://github.com/navarasu/onedark.nvim
    use 'Mofiqul/vscode.nvim' -- https://github.com/Mofiqul/vscode.nvim
    use 'loctvl842/monokai-pro.nvim' -- https://github.com/loctvl842/monokai-pro.nvim

    -- Completion
    use "hrsh7th/nvim-cmp" -- The completion plugin. https://github.com/hrsh7th/nvim-cmp
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "hrsh7th/cmp-cmdline"
    use "saadparwaiz1/cmp_luasnip" -- Snippet completions
    use "hrsh7th/cmp-nvim-lsp"
    use "hrsh7th/cmp-nvim-lsp-signature-help"

    use "L3MON4D3/LuaSnip" -- Snippet engine. https://github.com/L3MON4D3/LuaSnip
    use "rafamadriz/friendly-snippets" -- Collection of snippets for a bunch of languages. https://github.com/rafamadriz/friendly-snippets

    -- mason.nvim is a Neovim plugin that allows you to easily manage external editor tooling such as LSP servers, DAP servers, linters, and formatters through a single interface. It runs everywhere Neovim runs (across Linux, macOS, Windows, etc.), with only a small set of external requirements needed.
    use "williamboman/mason.nvim" -- https://github.com/williamboman/mason.nvim
    use "williamboman/mason-lspconfig.nvim" --
    use "neovim/nvim-lspconfig" -- Collection of Nvim LSP configs. https://github.com/neovim/nvim-lspconfig
    use "mfussenegger/nvim-dap" -- https://github.com/mfussenegger/nvim-dap
    use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } } -- https://github.com/rcarriga/nvim-dap-ui

    -- LSP extensions and language specific plugins. https://github.com/neovim/nvim-lspconfig/wiki/Language-specific-plugins
    use "b0o/schemastore.nvim" -- For jsonls LSP server. https://github.com/b0o/SchemaStore.nvim
    use "p00f/clangd_extensions.nvim" -- For clangd LSP server. https://github.com/p00f/clangd_extensions.nvim
    use "simrat39/rust-tools.nvim" -- LSP extensions for rust. https://github.com/simrat39/rust-tools.nvim
    use "mfussenegger/nvim-jdtls" -- For Java. https://github.com/mfussenegger/nvim-jdtls
    use "folke/neodev.nvim"

    -- Telescope
    use { "nvim-telescope/telescope.nvim", tag = "0.1.0" }
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' } -- Use fzf for search. https://github.com/nvim-telescope/telescope-fzf-native.nvim

    -- Treesitter
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    }
    use "p00f/nvim-ts-rainbow" -- Parentheses coloring.
    use "JoosepAlviste/nvim-ts-context-commentstring" -- Comment stuff out based on cursor position. https://github.com/JoosepAlviste/nvim-ts-context-commentstring
    use "nvim-treesitter/nvim-treesitter-context" -- https://github.com/nvim-treesitter/nvim-treesitter-context

    -- File explorer
    -- use {
    --     'nvim-tree/nvim-tree.lua', -- https://github.com/nvim-tree/nvim-tree.lua
    --     requires = {
    --         'nvim-tree/nvim-web-devicons', -- optional, for file icons
    --     },
    -- }
    -- use {
    --     "nvim-neo-tree/neo-tree.nvim",
    --     branch = "v2.x",
    --     requires = {
    --         "nvim-lua/plenary.nvim",
    --         "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    --         "MunifTanjim/nui.nvim",
    --     }
    -- }

    use "stevearc/oil.nvim"

    -- Git
    use "lewis6991/gitsigns.nvim"

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if packer_bootstrap then
        packer.sync()
    end
end)
