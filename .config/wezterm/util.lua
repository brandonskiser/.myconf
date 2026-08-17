local M = {}

---@return boolean
function M.is_work_laptop()
    return os.getenv('LOGNAME') == 'bskiser'
end

---@return boolean
function M.is_home_desktop()
    return os.getenv('USERNAME') == 'brand'
end

return M
