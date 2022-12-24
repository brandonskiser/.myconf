local util = require("kiser/lsp/util")

local schemas = require("schemastore").json.schemas()
-- local schemas = {
--     {
--         description = "NPM configuration file",
--         fileMatch = {
--             "package.json",
--         },
--         url = "https://json.schemastore.org/package.json"
--     },
-- }

local jsonls_opts = {
    settings = {
        json = {
            schemas = schemas,
            validate = { enable = true },
        }
    },
    -- commands = {
    --     Format = {
    --         function()
    --             -- This is deprecated, use vim.lsp.formatexpr or vim.lsp.buf.format instead.
    --             -- Don't think we even need this command since <space>f works...
    --             vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line "$", 0 })
    --         end,
    --     },
    -- },
}

require("lspconfig").jsonls.setup(vim.tbl_deep_extend("force", jsonls_opts, util.default_opts))

