local M = {}

--- @param buf integer Buffer id
--- @return boolean
function M.is_file_buf(buf)
    if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
        return false
    end

    -- A buffer is generally a file buffer if:
    -- 1. Its 'buftype' is empty (default for normal files).
    -- 2. It has a valid file path (not an empty string or special name like '[No Name]').
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    local bufname = vim.api.nvim_buf_get_name(buf)
    return buftype == "" and bufname ~= "" and not vim.endswith(bufname, "[No Name]")
end

--- @return integer[] List of buffer ids
function M.list_file_bufs()
    local file_bufs = {}
    local all_bufs = vim.api.nvim_list_bufs()

    for _, buf in ipairs(all_bufs) do
        if M.is_file_buf(buf) then
            file_bufs[#file_bufs + 1] = buf
        end
    end

    return file_bufs
end

--- Helper to delete a buffer without closing any windows.
---
--- Context: Deleting a buffer will close any windows open with that buffer, so
--- we need to update any windows to use a different buffer before deleting it.
---
--- @param buf integer Buffer id to delete
function M.buf_delete(buf)
    if buf == 0 then
        buf = vim.api.nvim_win_get_buf(0)
    end

    -- idk weird nil checks for handling different types of buffers (unlisted, scratch, etc)
    local buf_info = vim.fn.getbufinfo(buf)
    if buf_info == nil then return end
    --- @type vim.fn.getbufinfo.ret.item | nil
    buf_info = buf_info[1]
    if buf_info == nil then return end

    local windows = buf_info.windows
    windows = Lua_ext.filter(windows, function(win) return vim.api.nvim_win_get_buf(win) == buf end)

    -- Update windows open with the buf to delete to use a random file buffer,
    -- falling back to a scratch buffer if none exist.
    local file_bufs = Lua_ext.filter(M.list_file_bufs(),
        function(b) return b ~= buf end)
    local next_buf = file_bufs[1] or vim.api.nvim_create_buf(false, true)

    for _, win in ipairs(windows) do
        vim.api.nvim_win_set_buf(win, next_buf)
    end

    vim.api.nvim_buf_delete(buf, {})
end

return M
