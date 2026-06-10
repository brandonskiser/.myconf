--- Pure parser for Obsidian-style `[[wikilink]]` syntax. Handles bare
--- links and pipe-aliased links. Embeds (`![[target]]`) and header
--- anchors (`[[target#Header]]`) are deliberately out of scope and
--- treated as non-links per the project PRD.

local M = {}

--- @class kiser.obsidian.Link
--- @field target string
--- @field alias string?

--- Split a link body into `target` and optional `alias` halves.
--- @param body string  the text between `[[` and `]]`
--- @return kiser.obsidian.Link
local function split(body)
    local target, alias = body:match('^([^|]+)|(.+)$')
    if target then return { target = target, alias = alias } end
    return { target = body }
end

--- Enumerate every link in `text`, in source order. Embeds (`![[...]]`)
--- are excluded.
--- @param text string
--- @return kiser.obsidian.Link[]
function M.find_all(text)
    local out = {}
    for s, body in text:gmatch('()%[%[([^%]]+)%]%]') do
        local prev = s > 1 and text:sub(s - 1, s - 1) or ''
        if prev ~= '!' then out[#out + 1] = split(body) end
    end
    return out
end

--- Return the link spanning `(line, col)` if any. The link span is
--- inclusive of both `[[` and `]]` brackets, so a cursor anywhere on
--- the link text resolves. Embeds are excluded.
--- @param line string  current line text
--- @param col integer  1-indexed column under the cursor
--- @return kiser.obsidian.Link?
function M.find_at(line, col)
    for s, body, e in line:gmatch('()%[%[([^%]]+)%]%]()') do
        local prev = s > 1 and line:sub(s - 1, s - 1) or ''
        if prev ~= '!' and col >= s and col <= e - 1 then
            return split(body)
        end
    end
    return nil
end

return M
