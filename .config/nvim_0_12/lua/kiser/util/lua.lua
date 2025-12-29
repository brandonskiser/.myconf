local M = {}

---@generic T
---@param list T[]
---@param predicate fun(item: T): boolean
---@return T[]
function M.filter(list, predicate)
    local result = {}
    for _, value in ipairs(list) do
        if predicate(value) then
            result[#result + 1] = value
        end
    end
    return result
end

--- @generic T
---@param list T[]
---@param predicate fun(item: T): boolean
--- @return T|nil
function M.find(list, predicate)
    for _, value in ipairs(list) do
        if predicate(value) then
            return value
        end
    end
end

Lua_ext = M

return M
