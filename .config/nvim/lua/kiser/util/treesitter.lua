local M = {}

---@param bufnr nil|integer
M.get_buf_lang = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local ft = vim.bo[bufnr].filetype

    local result = vim.treesitter.language.get_lang(ft)
    if result then
        return result
    else
        ft = vim.split(ft, ".", { plain = true })[1]
        return vim.treesitter.language.get_lang(ft) or ft
    end
end

---@param bufnr? integer
---@return vim.treesitter.LanguageTree|nil
M.get_parser = function(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local success, parser = pcall(vim.treesitter.get_parser, bufnr)

    return success and parser or nil
end

return M
