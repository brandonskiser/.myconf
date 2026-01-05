local function req(module)
    local ok, _ = pcall(require, module)
    if not ok then
        print("Module `" .. module .. "` unable to be imported.")
    end
end

req("kiser.util")

req("kiser.defaults")
req("kiser.keymaps")
req("kiser.commands")
req("kiser.filetypes")
req("kiser.buflist")
req("kiser.diagnostics")

require("kiser.treesit_navigator").setup()
vim.api.nvim_create_user_command('TSNavigator', function()
    require("kiser.treesit_navigator").ts_tree_display()
end, { desc = 'Navigate the parsed treesitter tree' })

local gh = function(x) return "https://github.com/" .. x end

-- icons for use with aerial, oil, etc.
vim.pack.add({
    { src = gh("nvim-tree/nvim-web-devicons") }
})
require("nvim-web-devicons").setup()

vim.pack.add({
    { src = gh("nvim-lualine/lualine.nvim") }
})
require("lualine").setup()

vim.pack.add({
    { src = gh("akinsho/bufferline.nvim") }
})
require("bufferline").setup({
    options = {
        diagnostics = "nvim_lsp",
    }
})
vim.keymap.set("n", "<leader>bg", "<cmd>BufferLinePick<CR>", { desc = "go to buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "pick buffer to close" })
vim.keymap.set("n", "<S-Left>", "<cmd>BufferLineMovePrev<CR>", { desc = "move buffer left" })
vim.keymap.set("n", "<S-Right>", "<cmd>BufferLineMoveNext<CR>", { desc = "move buffer right" })
for i = 1, 9 do
    vim.keymap.set("n", "<leader>" .. tostring(i), "<cmd>BufferLineGoToBuffer " .. tostring(i) .. "<CR>")
end

vim.pack.add({
    { src = gh("lewis6991/gitsigns.nvim") }
})
if vim.fs.root(vim.env.PWD, ".git") ~= nil then
    require("gitsigns").setup()
end

vim.pack.add({
    { src = gh("nvim-mini/mini.base16") }
})

vim.pack.add({
    { src = gh("scottmckendry/cyberdream.nvim") }
})
require("cyberdream").setup({ transparent = true })

vim.pack.add({
    { src = gh("stevearc/oil.nvim") }
})
require("oil").setup()
vim.keymap.set("n", "\\", function()
    vim.cmd(":Oil")
    -- Janky way to center the screen when opening oil. Need to wait until after drawing.
    -- vim.fn.timer_start(50, function()
    --     vim.cmd.normal('zz')
    -- end)
end, { desc = "open in file explorer" })

vim.pack.add({
    { src = gh("kylechui/nvim-surround") }
})
require("nvim-surround").setup()



vim.pack.add({
    { src = gh("nvim-mini/mini.pick") }
})
require("mini.pick").setup({
    mappings = {
        mark = "<C-x>",
        mark_all = "<C-a>",
        choose_marked = "<C-e>",

        move_up = "<C-k>",
        move_down = "<C-j>",
        scroll_down = "<C-d>",
        scroll_up = "<C-u>",

        toggle_info = "<C-i>",
        toggle_preview = "<C-p>"
    }
})

vim.keymap.set("n", "<leader>ff", function()
    require("mini.pick").builtin.files(nil, {
        source = {
            cwd = require("oil").get_current_dir()
        }
    })
end, { noremap = true, desc = "find files" })

vim.keymap.set("n", "<leader>fh", function()
    require("mini.pick").builtin.help()
end, { noremap = true, desc = "find help tags" })

vim.keymap.set("n", "<leader>fg", function()
    require("mini.pick").builtin.grep_live(nil, {
        source = {
            cwd = require("oil").get_current_dir()
        }
    })
end, { noremap = true, desc = "live grep" })

vim.keymap.set("n", "<leader>fb", function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local lines_with_numbers = {}
    for lnum, line in ipairs(lines) do
        lines_with_numbers[#lines_with_numbers + 1] = lnum .. " | " .. line
    end

    --- @type string|nil
    local selected_line = require("mini.pick").start({
        source = {
            name = "Buffer lines",
            items = lines_with_numbers,
        }
    })
    if selected_line == nil then return end
    local idx = selected_line:find(" |")
    if idx == nil then return end

    local line_num = tonumber(selected_line:sub(1, idx - 1))
    vim.api.nvim_win_set_cursor(0, { line_num, 0 })
end, { noremap = true, desc = "current buffer fuzzy find" })

vim.keymap.set("n", "<leader>fp", function()
    require("mini.pick").builtin.files(
        nil,
        {
            source = {
                name = 'Find plugin files',
                cwd = vim.fs.joinpath(vim.fn.stdpath('data'), 'site', 'pack', 'core', 'opt')
            }
        }
    )
end, { noremap = true, desc = "find plugin files" })

vim.pack.add({
    { src = gh("nvim-mini/mini.extra") }
})
require("mini.extra").setup()

vim.keymap.set("n", "<leader>fl", function()
    require("mini.extra").pickers.lsp()
end, { noremap = true, desc = "find lsp" })

vim.keymap.set("n", "<leader>ft", function()
    require("mini.extra").pickers.treesitter()
end, { noremap = true, desc = "find treesitter" })

vim.keymap.set("n", "<leader>fB", function()
    require("mini.extra").pickers.buf_lines()
end, { noremap = true, desc = "all buffers fuzzy find" })


vim.pack.add({
    { src = gh("nvim-treesitter/nvim-treesitter") }
})
---@type fun(args: vim.api.keyset.create_autocmd.callback_args): boolean?
local install_parser_and_enable_features = function(event)
    local ts = require("nvim-treesitter")
    local lang = event.match

    -- Try to start the parser install for the language.
    local ok, task = pcall(ts.install, { lang }, { summary = true })
    if not ok then return end

    -- Wait for the installation to finish (up to 10 seconds).
    task:wait(10000)

    -- Enable syntax highlighting for the buffer
    ok, _ = pcall(vim.treesitter.start, event.buf, lang)
    if not ok then return end

    -- Enable other features as needed.

    -- Enable indentation based on treesitter for the buffer.
    -- vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    -- Enable folding based on treesitter for the buffer.
    -- vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
end
-- Install missing parsers on file open.
vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ui.treesitter", { clear = true }),
    pattern = { "*" },
    callback = install_parser_and_enable_features
})

-- add wesl
vim.filetype.add({
    extension = {
        wesl = 'wesl'
    }
})
vim.api.nvim_create_autocmd("User", {
    pattern = "TSUpdate",
    callback = function()
        require("nvim-treesitter.parsers").wesl = {
            install_info = {
                revision = '3fa2b96bf5c217dae9bf663e2051fcdad0762c19',
                url = 'https://github.com/wgsl-tooling-wg/tree-sitter-wesl',
                queries = 'queries',
            },
            filetype = 'wesl',
            tier = 1,
        }
        vim.treesitter.language.register('wesl', { 'wesl' })
    end
})

vim.pack.add({
    { src = gh("nvim-treesitter/nvim-treesitter-context") }
})
require("treesitter-context").setup({ mode = 'cursor', max_lines = 4 })

vim.pack.add({
    { src = gh("stevearc/aerial.nvim") }
})
require("aerial").setup()
vim.api.nvim_set_keymap("n", "<leader>at", "<cmd>AerialToggle!<CR>", { desc = "toggle aerial" })
vim.keymap.set("n", "<leader>fa", function()
    require("kiser.mini-aerial").pick()
end, { noremap = true, desc = "find current buffer symbols" })

vim.pack.add({
    { src = gh("mrcjkb/rustaceanvim"), version = vim.version.range("^6") }
})
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == "rust_analyzer" then
            vim.keymap.set("n", "K", ":RustLsp hover actions<CR>",
                { noremap = true, silent = true, buffer = ev.buf }
            )
        end
    end
})
vim.g.rustaceanvim = {
    server = {
        settings = {
            ["rust-analyzer"] = {
                -- rust-analyzer settings: https://rust-analyzer.github.io/book/configuration.html
                checkOnSave = true,
                check = {
                    command = "clippy",
                    allTargets = true -- Setting to false fixes issue with no_std crates panic_handler conflicting definitions.
                },
                rustfmt = {
                    extraArgs = { "+nightly" }
                },
                cargo = {
                    -- features = { 'phoenix' }
                }
            }
        }
    }
}

vim.pack.add({
    { src = gh("neovim/nvim-lspconfig") }
})

local function setup_lsp()
    local home_dir = os.getenv("HOME")
    if not home_dir then return end

    -- enable all lsp servers under ~/.config/nvim/lsp/
    -- local local_lsp_dir = require('kiser.util.path').join(home_dir, '.config', 'nvim', 'lsp')
    local local_lsp_dir = require("kiser.util.path").join(vim.fn.stdpath("config"), "lsp")

    local lsp_configs = {}
    for _, fpath in pairs(vim.api.nvim_get_runtime_file("lsp/*.lua", true)) do
        if fpath:match(local_lsp_dir) then
            -- :t - get tail of the file name
            -- :r - root of the file name (remove extension)
            local server_name = vim.fn.fnamemodify(fpath, ":t:r")
            table.insert(lsp_configs, server_name)
        end
    end
    vim.lsp.enable(lsp_configs)

    vim.api.nvim_create_autocmd("LspAttach", {
        --- @param ev vim.api.keyset.create_autocmd.callback_args
        callback = function(ev)
            require("kiser.util.lsp").default_lsp_keymaps(ev.buf)
        end
    })
end
setup_lsp()

-- vim.pack.del({ gh("saghen/blink.cmp") })
-- vim.pack.add({
--     -- { src = gh("saghen/blink.cmp"), version = vim.version.range("^1") }
--     { src = gh("saghen/blink.cmp"), version = "v1.8.0" }
-- })
-- require("blink.cmp").setup()


vim.pack.add({
    { src = gh("hrsh7th/cmp-buffer") },
    { src = gh("hrsh7th/cmp-path") },
    { src = gh("hrsh7th/cmp-cmdline") },
    { src = gh("hrsh7th/cmp-nvim-lsp") },
    { src = gh("hrsh7th/cmp-nvim-lsp-signature-help") },
    { src = gh("p00f/clangd_extensions.nvim") },
    { src = gh("hrsh7th/nvim-cmp") }
})
vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    once = true,
    callback = function()
        local cmp = require("cmp")
        cmp.setup({
            -- snippet = {
            --     expand = function(args)
            --         luasnip.lsp_expand(args.body)
            --     end
            -- },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },
            preselect = cmp.PreselectMode.None,
            mapping = {
                ["<C-k>"] = cmp.mapping.select_prev_item(),
                ["<C-j>"] = cmp.mapping.select_next_item(),
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                -- ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-c>"] = cmp.mapping.abort(),
                -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                -- ["<Tab>"] = cmp.mapping(function(fallback)
                --     -- if cmp.visible() then
                --     --     cmp.select_next_item()
                --     -- elseif luasnip.expandable() then
                --     if luasnip.expandable() then
                --         luasnip.expand()
                --     elseif luasnip.expand_or_jumpable() then
                --         luasnip.expand_or_jump()
                --     else
                --         fallback()
                --     end
                -- end, {
                --     "i",
                --     "s",
                -- }),
                -- ["<S-Tab>"] = cmp.mapping(function(fallback)
                --     -- Causes issues in insert mode when pressing tab
                --     -- on an incomplete snippet. Need to find a solution.
                --     -- if cmp.visible() then
                --     --     cmp.select_prev_item()
                --     -- elseif luasnip.jumpable(-1) then
                --     if luasnip.jumpable(-1) then
                --         luasnip.jump(-1)
                --     else
                --         fallback()
                --     end
                -- end, {
                --     "i",
                --     "s",
                -- }),
            },
            sorting = {
                comparators = {
                    cmp.config.compare.offset,
                    cmp.config.compare.exact,
                    cmp.config.compare.recently_used,
                    require("clangd_extensions.cmp_scores"),
                    cmp.config.compare.kind,
                    cmp.config.compare.sort_text,
                    cmp.config.compare.length,
                    cmp.config.compare.order,
                },
            },
            formatting = {
                fields = { "kind", "abbr", "menu" },
                format = function(entry, vim_item)
                    vim_item.menu = ({
                        nvim_lsp = "[LSP]",
                        luasnip = "[Snippet]",
                        buffer = "[Buffer]",
                        path = "[Path]",
                    })[entry.source.name]
                    return vim_item
                end
            },
            -- List of sources: https://github.com/hrsh7th/nvim-cmp/wiki/List-of-sources
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "nvim_lsp_signature_help" },
                { name = "luasnip" },
                { name = "buffer" },
                { name = "path" },
            }),
        })
    end
})

vim.pack.add({
    { src = gh("folke/lazydev.nvim") }
})
vim.api.nvim_create_autocmd('FileType', {
    pattern = 'lua',
    callback = function()
        require('lazydev').setup()
    end
})

-- req('kiser.plugins.obsidian')

-- Set colorscheme after all plugins are done installing
req("kiser.colorscheme")
