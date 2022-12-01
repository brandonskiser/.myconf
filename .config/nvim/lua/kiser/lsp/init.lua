local ok, _ = pcall(require, "lspconfig")
if not ok then
    print("lspconfig is not available")
    return
end

require("kiser/lsp/lsp")
