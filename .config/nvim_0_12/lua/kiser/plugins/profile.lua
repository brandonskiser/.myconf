local M = {}

--- @class ProfileEntry
--- @field name string
--- @field time_ms number

--- @type ProfileEntry[]
local profile_data = {}

--- Require a plugin module and record load time
--- @param module string
function M.req(module)
    local start = vim.loop.hrtime()
    local ok, err = pcall(require, "kiser.plugins." .. module)
    local elapsed_ms = (vim.loop.hrtime() - start) / 1e6

    table.insert(profile_data, { name = module, time_ms = elapsed_ms })

    if not ok then
        print("Plugin module `" .. module .. "` unable to be imported: " .. tostring(err))
    end
end

--- Display profile results sorted by load time (descending)
function M.show()
    local sorted = vim.deepcopy(profile_data)
    table.sort(sorted, function(a, b) return a.time_ms > b.time_ms end)

    local lines = { "Plugin Load Times:", "" }
    local total = 0
    for _, entry in ipairs(sorted) do
        table.insert(lines, string.format("%8.2f ms  %s", entry.time_ms, entry.name))
        total = total + entry.time_ms
    end
    table.insert(lines, "")
    table.insert(lines, string.format("%8.2f ms  TOTAL", total))

    print(table.concat(lines, "\n"))
end

--- Get raw profile data
--- @return ProfileEntry[]
function M.data()
    return profile_data
end

return M
