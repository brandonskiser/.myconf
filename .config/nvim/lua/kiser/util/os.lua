local M = {}

---Returns true if this is running on MacOS, false otherwise
---@return boolean
function M.is_linux()
    return vim.loop.os_uname().sysname == "Linux"
end

---Returns true if this is running on MacOS, false otherwise
---@return boolean
function M.is_mac()
    return vim.loop.os_uname().sysname == "Darwin"
end

return M

