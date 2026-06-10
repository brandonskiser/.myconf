local M = {}

local PATH_SEPARATOR = require('kiser.util.os').is_windows() and '\\' or '/'

---Joins the provided arguments with the path separator for
--the current OS.
---@param ... string | string[]
---@return string
---@deprecated use vim.fs.joinpath instead
function M.join(...)
    local result = table.concat(vim.iter({ ... }):flatten(math.huge):totable(), PATH_SEPARATOR):gsub(
    PATH_SEPARATOR .. '+', PATH_SEPARATOR)
    return result
end

---Finds the first directory containing one of the file names provided in `markers`
--starting from `bufname`.
---@param markers string[] List of file names to search for.
---@param bufname string? Path to starting file, defaults to the current buffer.
---@return string?
---@deprecated use vim.fs.root instead
function M.find_root(markers, bufname)
    bufname = bufname or vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local dirname = vim.fn.fnamemodify(bufname, ':p:h')
    local getparent = function(p)
        return vim.fn.fnamemodify(p, ':h')
    end
    while getparent(dirname) ~= dirname do
        for _, marker in ipairs(markers) do
            if vim.loop.fs_stat(vim.fs.joinpath(dirname, marker)) then
                return dirname
            end
        end
        dirname = getparent(dirname)
    end
end

return M
