-- rustaceanvim is not managed by lazy since it just works out of the box somehow.
local lsp_util = require("kiser.plugins.lsp.util")


vim.g.rustaceanvim = {
    server = lsp_util.make_opts {
        on_attach = function(_, bufnr)
            -- Add keymaps here.
            vim.keymap.set("n", "K", ":RustLsp hover actions<CR>", { noremap = true, silent = true, buffer = bufnr })
        end,
        settings = {
            ["rust-analyzer"] = {
                -- rust-analyzer settings: https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
                checkOnSave = {
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
