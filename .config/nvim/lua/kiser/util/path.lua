local M = {}

local IS_WINDOWS = vim.loop.os_uname().version:match('Windows')

local PATH_SEPARATOR = IS_WINDOWS and '\\' or '/'

function M.join(...)
  local result = table.concat(vim.tbl_flatten {...}, PATH_SEPARATOR):gsub(PATH_SEPARATOR .. '+', PATH_SEPARATOR)
  return result
end

function M.find_root(markers, bufname)
    bufname = bufname or vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    local dirname = vim.fn.fnamemodify(bufname, ':p:h')
    local getparent = function(p)
        return vim.fn.fnamemodify(p, ':h')
    end
    while getparent(dirname) ~= dirname do
        for _, marker in ipairs(markers) do
            if vim.loop.fs_stat(M.join(dirname, marker)) then
                return dirname
            end
        end
        dirname = getparent(dirname)
    end
end

return M
