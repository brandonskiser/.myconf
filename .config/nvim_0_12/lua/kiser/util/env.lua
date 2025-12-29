local M = {}

function M.is_work_laptop()
    return os.getenv('LOGNAME') == 'bskiser'
end

return M
