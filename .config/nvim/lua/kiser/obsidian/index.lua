--- In-memory index of vault notes: `by_id`, `by_alias`, `by_tag`,
--- `paths`. Built fresh on every call - the vault is small enough that
--- a 1-time walk is faster than any caching strategy that could go
--- stale on `:cd` or `BufWritePost`.

local frontmatter = require('kiser.obsidian.frontmatter')

local M = {}

--- @class kiser.obsidian.IndexOpts
--- @field exclude_dirs string[]?       directory basenames to skip anywhere

--- @class kiser.obsidian.Index
--- @field by_id table<string, string>          -- id -> abs path
--- @field by_alias table<string, string>       -- lower(alias) -> abs path
--- @field by_tag table<string, string[]>       -- tag -> [abs path, ...]
--- @field paths string[]                        -- every indexed abs path

--- Walk `roots` and build an index of every `.md` file found, parsing
--- frontmatter for each. Directories matching any `exclude_dirs`
--- basename are pruned anywhere in the tree.
--- @param roots string[]                vault root absolute paths
--- @param opts kiser.obsidian.IndexOpts?
--- @return kiser.obsidian.Index
function M.build(roots, opts)
    opts = opts or {}
    local exclude = {}
    for _, d in ipairs(opts.exclude_dirs or {}) do exclude[d] = true end
    local out = { by_id = {}, by_alias = {}, by_tag = {}, paths = {} }

    for _, root in ipairs(roots) do
        local files = vim.fs.find(function(name, p)
            for segment in p:gmatch('[^/]+') do
                if exclude[segment] then return false end
            end
            return name:match('%.md$') ~= nil
        end, { type = 'file', path = root, limit = math.huge })

        for _, path in ipairs(files) do
            out.paths[#out.paths + 1] = path
            local fm = frontmatter.parse_file(path)
            if fm.id then out.by_id[fm.id] = path end
            for _, a in ipairs(fm.aliases) do out.by_alias[a:lower()] = path end
            for _, t in ipairs(fm.tags) do
                local b = out.by_tag[t] or {}; b[#b + 1] = path
                out.by_tag[t] = b
            end
        end
    end
    return out
end

return M
