-- rustaceanvim is not managed by lazy since it just works out of the box somehow.
local lsp_util = require("kiser.plugins.lsp.util")


vim.g.rustaceanvim = {
    server = lsp_util.make_opts {
        on_attach = function(_, bufnr)
            -- Add keymaps here.
            vim.keymap.set("n", "K", ":RustLsp hover actions<CR>", { noremap = true, silent = true, buffer = bufnr })
            for _, method in ipairs({ "textDocument/diagnostic", "workspace/diagnostic" }) do
                -- https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
                local default_diagnostic_handler = vim.lsp.handlers[method]
                vim.lsp.handlers[method] = function(err, result, context, config)
                    if err ~= nil and err.code == -32802 then
                        return
                    end
                    return default_diagnostic_handler(err, result, context, config)
                end
            end
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
