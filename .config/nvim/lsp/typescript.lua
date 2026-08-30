-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ts_ls.lua
-- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md

return {
    cmd = {
        vim.fn.has("win32") == 1 and "typescript-language-server.cmd" or "typescript-language-server",
        "--stdio",
    },
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
    },
    -- Prefer the nearest TypeScript/Node project over an enclosing Git root.
    -- This repo keeps the package in a subdirectory of the Git worktree.
    root_markers = {
        "tsconfig.json",
        "jsconfig.json",
        "package.json",
        ".git",
    },

    init_options = { hostInfo = "neovim" },
    single_file_support = true,
    handlers = {
        -- handle rename request for certain code actions like extracting functions / types
        ['_typescript.rename'] = function(_, result, ctx)
            local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
            vim.lsp.util.show_document({
                uri = result.textDocument.uri,
                range = {
                    start = result.position,
                    ['end'] = result.position,
                },
            }, client.offset_encoding)
            vim.lsp.buf.rename()
            return vim.NIL
        end,
    },
}
