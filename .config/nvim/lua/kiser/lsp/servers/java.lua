local util = require("kiser/lsp/util")

local config = util.default_opts

require'lspconfig'.jdtls.setup(config)
-- require("jdtls").start_or_attach {
--     on_attach
-- }
