--- mini.pick adapters. Item-providers (`tag_items`, `tag_paths`,
--- `search_paths`) are pure functions over an index and unit-tested. The
--- UI invocations below open mini.pick and are exercised manually.

local M = {}

--- @class kiser.obsidian.TagItem
--- @field tag string
--- @field count integer            -- number of notes with this tag
--- @field text string               -- mini.pick display + match field

--- @class kiser.obsidian.PathItem
--- @field path string

--- Stage-1 tags picker items, sorted alphabetically by tag. The `text`
--- field is what mini.pick's matcher and renderer operate on.
--- @param idx kiser.obsidian.Index
--- @return kiser.obsidian.TagItem[]
function M.tag_items(idx)
    local out = {}
    for tag, paths in pairs(idx.by_tag) do
        out[#out + 1] = {
            tag = tag,
            count = #paths,
            text = ('%s (%d)'):format(tag, #paths),
        }
    end
    table.sort(out, function(a, b) return a.tag < b.tag end)
    return out
end

--- Absolute paths tagged with `tag`. Empty list when the tag is unknown.
--- @param idx kiser.obsidian.Index
--- @param tag string
--- @return string[]
function M.tag_paths(idx, tag) return idx.by_tag[tag] or {} end

--- Every indexed path. Used by callers that want a flat note list.
--- @param idx kiser.obsidian.Index
--- @return string[]
function M.search_paths(idx) return idx.paths end

-- ---------------------------------------------------------------------------
-- UI invocations. Not unit-tested.
-- ---------------------------------------------------------------------------

local config = require('kiser.obsidian.config')
local index_mod = require('kiser.obsidian.index')
local link = require('kiser.obsidian.link')
local note = require('kiser.obsidian.note')

--- Lazily fetch mini.pick. Required lazily so this module loads before
--- mini.pick if call order ever flips during setup.
--- @return table  the mini.pick module
local function mp() return require('mini.pick') end

--- Active workspace roots. If cwd lives under a configured workspace,
--- scope to that workspace; otherwise fall back to the full list. The
--- second return value is the cwd we hand to mini.pick (kept short so
--- match strings are short).
--- @param cfg kiser.obsidian.Config
--- @return string[] roots, string root_for_cwd
local function active_roots(cfg)
    local cwd = vim.fn.getcwd()
    for _, ws in ipairs(cfg.workspaces) do
        if cwd == ws or vim.startswith(cwd .. '/', ws .. '/') then
            return { ws }, ws
        end
    end
    return cfg.workspaces, cfg.vault_root
end

--- Walk the active vault on every call. Caching is more risk than win
--- given the small vault size (stale results, wrong-cwd indexes).
--- @param cfg kiser.obsidian.Config
--- @param roots string[]
--- @return kiser.obsidian.Index
local function build(cfg, roots)
    return index_mod.build(roots, { exclude_dirs = cfg.exclude_dirs })
end

--- Build the rg `--glob` list excluding configured dirs, plus extras.
--- @param cfg kiser.obsidian.Config
--- @param extra string[]?  additional `!pattern` globs (relative to cwd)
--- @return string[]
local function globs_for(cfg, extra)
    local out = {}
    for _, d in ipairs(cfg.exclude_dirs or {}) do
        out[#out + 1] = '!**/' .. d .. '/**'
    end
    for _, g in ipairs(extra or {}) do out[#out + 1] = g end
    return out
end

--- Open a search picker scoped to the active workspace, excluding any
--- configured directories from the result set.
--- @param cfg kiser.obsidian.Config
--- @param q string?  optional initial pattern; runs a one-shot grep when set
function M.search(cfg, q)
    local _, root = active_roots(cfg)
    local globs = globs_for(cfg)
    if q and q ~= '' then
        return mp().builtin.grep({ pattern = q, globs = globs },
            { source = { cwd = root } })
    end
    return mp().builtin.grep_live({ globs = globs }, { source = { cwd = root } })
end

--- Two-stage tags picker. Stage 1 picks a tag; stage 2 lists notes with
--- that tag and opens the chosen one.
--- @param cfg kiser.obsidian.Config
function M.tags(cfg)
    local roots, root = active_roots(cfg)
    local idx = build(cfg, roots)
    mp().start({ source = {
        name = 'Vault tags',
        items = M.tag_items(idx),
        choose = function(item)
            if not item then return end
            -- Stage 2 must start AFTER stage-1 teardown completes, otherwise
            -- the new picker steals the closing picker's window.
            vim.schedule(function()
                mp().start({ source = {
                    name = ('Notes tagged #%s'):format(item.tag),
                    cwd = root,
                    items = M.tag_paths(idx, item.tag),
                } })
            end)
        end,
    } })
end

--- Open a backlinks picker for the current buffer. Scopes to the active
--- workspace; excludes the templates dir and the buffer itself.
--- @param cfg kiser.obsidian.Config
function M.backlinks(cfg)
    local cur = vim.api.nvim_buf_get_name(0)
    if not config.is_in_vault(cfg, cur) then return end
    local fm = require('kiser.obsidian.frontmatter').parse_file(cur)
    if not fm.id then return vim.notify('No id on current note', vim.log.levels.WARN) end
    local _, root = active_roots(cfg)
    local rel = vim.fn.fnamemodify(cur, ':p'):sub(#root + 2) -- strip "<root>/"
    -- ripgrep matches `[[id` left-truncated so it catches `[[id]]` and
    -- `[[id|alias]]` in the same pass. Note ids only ever contain
    -- `[A-Za-z0-9_-]` (see note.gen_id), none of which are rg regex
    -- metachars, so the id can go in unescaped.
    mp().builtin.grep({
        pattern = ('\\[\\[%s'):format(fm.id),
        globs = globs_for(cfg, { '!' .. rel }),
    }, { source = { cwd = root } })
end

--- Resolve and edit the wikilink under the cursor. Tries `idx.by_id`
--- first then `idx.by_alias` (case-insensitive). Notifies on miss.
--- @param cfg kiser.obsidian.Config
function M.follow_link(cfg)
    local lk = link.find_at(vim.api.nvim_get_current_line(),
        vim.api.nvim_win_get_cursor(0)[2] + 1)
    if not lk then return vim.notify('No [[wikilink]] under cursor', vim.log.levels.WARN) end
    local roots = active_roots(cfg)
    local idx = build(cfg, roots)
    local target = idx.by_id[lk.target] or idx.by_alias[lk.target:lower()]
    if not target then return vim.notify('Link target not found: ' .. lk.target, vim.log.levels.WARN) end
    vim.cmd.edit(vim.fn.fnameescape(target))
end

--- Open the current buffer in Obsidian.app via `obsidian://open`. macOS
--- only (uses `open`); no-op outside the vault.
--- @param cfg kiser.obsidian.Config
function M.open_in_obsidian(cfg)
    local cur = vim.api.nvim_buf_get_name(0)
    if not config.is_in_vault(cfg, cur) then return end
    local url = 'obsidian://open?path=' .. vim.uri_encode(vim.fn.fnamemodify(cur, ':p'))
    vim.system({ 'open', url }, { detach = true })
end

--- Prompt for a title, create a new note, and edit it. Aborts cleanly
--- on empty input.
--- @param opts { dir: string, tags: string[]?, prompt: string? }
function M.new_note(opts)
    local title = vim.fn.input(opts.prompt or 'Title: ')
    if title == '' then
        return vim.notify('No title provided, not creating note.', vim.log.levels.INFO)
    end
    local path = note.new({
        id = note.gen_id(title),
        title = title,
        aliases = { title },
        tags = opts.tags or {},
        dir = opts.dir,
    })
    vim.cmd.edit(vim.fn.fnameescape(path))
end

return M
