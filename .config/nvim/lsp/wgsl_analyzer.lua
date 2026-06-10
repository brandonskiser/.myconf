-- return vim.lsp.config("wgsl_analyzer", {
--     cmd = { "wgsl-analyzer" },
--     filetypes = { "wgsl", "wesl" },
--     root_markers = { "wgsl.toml", "Cargo.toml", ".git" },
--     settings = {
--         ["wgsl-analyzer"] = {
--             diagnostics = {
--                 nagaValidation = false,
--             },
--             inlayHints = {
--                 typeHints = false,
--             },
--         },
--     },
-- })

--- @type vim.lsp.Config
return {
    cmd = { "wgsl-analyzer" },
    filetypes = { "wgsl", "wesl" },
    root_markers = { "wgsl.toml", "Cargo.toml", ".git" },
    settings = {
        ["wgsl-analyzer"] = {
            diagnostics = {
                nagaValidation = false,
            },
            inlayHints = {
                typeHints = false,
            },
        },
    },
}
