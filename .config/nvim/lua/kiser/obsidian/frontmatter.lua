--- Pure YAML frontmatter parser scoped to the three keys this plugin
--- cares about: `id`, `aliases`, `tags`. Handles both block-style
--- (`- foo`) and flow-style (`[a, b]`) lists, with or without quotes.
--- Unknown keys are ignored. Malformed or absent blocks yield defaults.

local M = {}

--- @class kiser.obsidian.Frontmatter
--- @field id string?
--- @field aliases string[]
--- @field tags string[]

--- Strip a single layer of surrounding single or double quotes, if any.
--- @param s string
--- @return string
local function unquote(s)
    return s:match('^"(.*)"$') or s:match("^'(.*)'$") or s
end

--- Parse YAML frontmatter from a markdown string. Returns defaults on
--- absent or malformed (unterminated) blocks. Unknown keys are ignored.
--- @param text string
--- @return kiser.obsidian.Frontmatter
function M.parse(text)
    local out = { id = nil, aliases = {}, tags = {} }
    local block = text:match('^%-%-%-\n(.-)\n%-%-%-')
    if not block then return out end

    local lines = vim.split(block, '\n', { plain = true })
    local i = 1
    while i <= #lines do
        local key, rest = lines[i]:match('^([%w_]+):%s*(.*)$')
        if key == 'id' then
            out.id = unquote(rest); i = i + 1
        elseif key == 'aliases' or key == 'tags' then
            local items = {}
            local flow = rest:match('^%[(.*)%]%s*$')
            if flow then
                for item in flow:gmatch('([^,]+)') do
                    local t = item:match('^%s*(.-)%s*$')
                    if t ~= '' then items[#items + 1] = unquote(t) end
                end
                i = i + 1
            else
                i = i + 1
                while i <= #lines do
                    local item = lines[i]:match('^%s+%-%s*(.+)$')
                    if not item then break end
                    items[#items + 1] = unquote(item); i = i + 1
                end
            end
            out[key] = items
        else
            i = i + 1
        end
    end
    return out
end

--- Read a file from disk and parse its frontmatter. Reads the leading
--- 4 KiB only - sufficient for any realistic frontmatter. Missing or
--- unreadable files yield the defaults instead of raising.
--- @param path string
--- @return kiser.obsidian.Frontmatter
function M.parse_file(path)
    local fd = vim.uv.fs_open(path, 'r', 438)
    if not fd then return { id = nil, aliases = {}, tags = {} } end
    local stat = vim.uv.fs_fstat(fd)
    local data = vim.uv.fs_read(fd, math.min(stat.size, 4096), 0) or ''
    vim.uv.fs_close(fd)
    return M.parse(data)
end

return M
