function log(arg)
    vim.notify(vim.inspect(arg))
end

local ts = require("kiser.util.treesitter")
local lang = ts.get_buf_lang()
local query = vim.treesitter.query.get(lang, "aerial")
-- log(query)
local parser = vim.treesitter.get_parser()
local tree = parser:parse()[1]
-- tree:root()
log(tree:root():child_count())

