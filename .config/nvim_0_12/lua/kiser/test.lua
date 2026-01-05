function log(arg)
    vim.notify(vim.inspect(arg))
end

local treesitter_stuff = function()
    local ts = require("kiser.util.treesitter")
    local lang = ts.get_buf_lang()
    local query = vim.treesitter.query.get(lang, "aerial")
    -- log(query)
    local parser = vim.treesitter.get_parser()
    local tree = parser:parse()[1]
    -- tree:root()
    log(tree:root():child_count())
end

local diagnostics_stuff = function()
    local diagnostics = vim.diagnostic.get()
    -- log(diagnostics)
    table.sort(diagnostics, function(a, b) return a.severity > b.severity end)
    -- diagnostics = vim.tbl_map(function(v) return v.severity end, diagnostics)
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
    log(diagnostics)
end

diagnostics_stuff()
