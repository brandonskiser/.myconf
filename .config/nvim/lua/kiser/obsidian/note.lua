--- New-note creation and id generation. The id generator shells out to
--- `gdate` (macOS, via Homebrew coreutils) or `date` and matches the
--- format used by the existing vault: ISO-8601 UTC with colons stripped,
--- followed by `_<slug-or-random4>`.

local M = {}

--- @class kiser.obsidian.NoteSpec
--- @field id string
--- @field title string
--- @field aliases string[]?
--- @field tags string[]?
--- @field dir string

-- Seed Lua's PRNG once per Lua state so random_suffix doesn't yield the
-- same letters on every fresh nvim startup.
math.randomseed(vim.uv.hrtime())

--- @return boolean true on macOS (where coreutils ships as `gdate`).
local function is_mac()
    return vim.uv.os_uname().sysname == 'Darwin'
end

--- Slugify a title for use in a file name: lowercase, spaces -> hyphens,
--- drop everything outside `[A-Za-z0-9-]`.
--- @param title string
--- @return string
local function slugify(title)
    return (title:gsub(' ', '-'):gsub('[^A-Za-z0-9%-]', '')):lower()
end

--- UTC ISO-8601 timestamp with colons stripped, ending in `Z`. Errors
--- (rather than returning a malformed id) if the date binary fails.
--- @return string
local function utc_stamp()
    local cmd = is_mac() and 'gdate' or 'date'
    local raw = vim.fn.system(cmd .. ' -u --iso-8601=seconds')
    if vim.v.shell_error ~= 0 or raw == '' then
        error(("note id timestamp: %q failed (shell_error=%d)"):format(cmd, vim.v.shell_error))
    end
    raw = raw:gsub(':', '')
    local plus = raw:find('+', 1, true)
    if plus then raw = raw:sub(1, plus - 1) end
    return (raw:gsub('%s+$', '')) .. 'Z'
end

--- Four random uppercase letters. Used as the id suffix when the caller
--- has no title.
--- @return string
local function random_suffix()
    local out = {}
    for i = 1, 4 do out[i] = string.char(math.random(65, 90)) end
    return table.concat(out)
end

--- Generate a vault-format note id: `<utc-iso-no-colons>Z_<slug-or-random4>`.
--- @param title string?  nil yields a random four-letter suffix
--- @return string
function M.gen_id(title)
    local suffix = (title and title ~= '') and slugify(title) or random_suffix()
    return utc_stamp() .. '_' .. suffix
end

--- Render the line-list for a brand-new note: frontmatter block, blank
--- line, `# <title>` heading, trailing blank.
--- @param spec kiser.obsidian.NoteSpec
--- @return string[]
local function render(spec)
    local lines = { '---', 'id: ' .. spec.id, 'aliases:' }
    for _, a in ipairs(spec.aliases or {}) do lines[#lines + 1] = '  - ' .. a end
    lines[#lines + 1] = 'tags:'
    for _, t in ipairs(spec.tags or {}) do lines[#lines + 1] = '  - ' .. t end
    lines[#lines + 1] = '---'; lines[#lines + 1] = ''
    lines[#lines + 1] = '# ' .. spec.title; lines[#lines + 1] = ''
    return lines
end

--- Write a brand-new note to `<dir>/<id>.md`. Creates the parent dir if
--- needed. Errors instead of overwriting an existing file or losing
--- bytes on a short write.
--- @param spec kiser.obsidian.NoteSpec
--- @return string path  the absolute path of the file written
function M.new(spec)
    local path = vim.fs.joinpath(spec.dir, spec.id .. '.md')
    if vim.uv.fs_stat(path) then
        error(string.format('refusing to overwrite existing note: %s', path))
    end
    vim.fn.mkdir(spec.dir, 'p')
    local data = table.concat(render(spec), '\n')
    local fd = assert(vim.uv.fs_open(path, 'w', 420))
    local written = vim.uv.fs_write(fd, data)
    vim.uv.fs_close(fd)
    if written ~= #data then
        error(string.format('short write to %s: %d of %d bytes', path, written or -1, #data))
    end
    return path
end

return M
