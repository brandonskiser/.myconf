vim.pack.add({
    { src = gh("nvim-treesitter/nvim-treesitter") }
})

local function install_parser_and_enable_features(event)
    local ts = require("nvim-treesitter")
    local lang = event.match
    local ok, task = pcall(ts.install, { lang }, { summary = true })
    if not ok then return end
    task:wait(10000)
    pcall(vim.treesitter.start, event.buf, lang)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ui.treesitter", { clear = true }),
    pattern = { "*" },
    callback = install_parser_and_enable_features
})

-- wesl support
vim.filetype.add({ extension = { wesl = 'wesl' } })
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
