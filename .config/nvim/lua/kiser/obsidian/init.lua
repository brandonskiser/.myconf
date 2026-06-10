--- Public entry point for `kiser.obsidian`. Owns `setup()`, the keymap
--- surface, and trivial pass-throughs to the `pick` module so callers
--- never have to reach past this file. Submodules:
---
--- - `kiser.obsidian.config`      - defaults + path predicates
--- - `kiser.obsidian.frontmatter` - YAML frontmatter parser (pure)
--- - `kiser.obsidian.link`        - `[[wikilink]]` parser (pure)
--- - `kiser.obsidian.note`        - new-note creation + id generator
--- - `kiser.obsidian.index`       - vault walker / index builder
--- - `kiser.obsidian.pick`        - mini.pick adapters

local config = require('kiser.obsidian.config')
local pick = require('kiser.obsidian.pick')

local M = {}

--- Resolved config, populated by `setup`.
--- @type kiser.obsidian.Config?
local _cfg = nil

--- True after the first `setup()` call. `setup` is idempotent on `_cfg`
--- but autocmds and keymaps are wired exactly once.
local _wired = false

--- Open a full-text picker over the active workspace. With a non-empty
--- `query`, runs a one-shot grep with that pattern; otherwise opens the
--- live-grep picker.
--- @param query string?
function M.search(query) pick.search(_cfg, query) end

--- Open the two-stage tags picker: stage 1 selects a tag, stage 2 lists
--- the notes in the active workspace tagged with it.
function M.tags() pick.tags(_cfg) end

--- Pick over notes whose body references the current note's frontmatter
--- id via `[[id]]` or `[[id|alias]]`. No-op outside the vault or on
--- notes without an id.
function M.backlinks() pick.backlinks(_cfg) end

--- Resolve the `[[wikilink]]` under the cursor (id-first, alias-fallback)
--- and edit the target. `vim.notify` on miss.
function M.follow_link() pick.follow_link(_cfg) end

--- Hand the current buffer off to Obsidian.app via `obsidian://open`.
--- macOS only; no-op outside the vault.
function M.open_in_obsidian() pick.open_in_obsidian(_cfg) end

--- Prompt for a title and create a new note. Caller supplies `dir` and
--- `tags`; aliases default to `{ title }`. Aborts cleanly on empty input.
--- @param opts { dir: string, tags: string[]?, prompt: string? }
function M.new_note(opts) pick.new_note(opts) end

--- Bind every leader-keymap on the given buffer. Called from the vault
--- BufRead/BufNewFile autocmd so non-vault buffers keep their default
--- mappings (notably `gd` -> LSP go-to-definition).
--- @param buf integer buffer id
--- @param cfg kiser.obsidian.Config
local function buf_keymaps(buf, cfg)
    local maps = {
        { '<leader>os',  M.search,         'obsidian search' },
        { '<leader>oS',  function() M.search(vim.fn.input('Search: ')) end, 'obsidian search w/ initial query' },
        { '<leader>ot',  M.tags,           'obsidian tags' },
        { '<leader>ob',  M.backlinks,      'obsidian backlinks' },
        { '<leader>ofl', M.follow_link,    'obsidian follow link' },
        { 'gd',          M.follow_link,    'obsidian follow link' },
        { '<leader>oo',  M.open_in_obsidian, 'obsidian open' },
        { '<leader>onz', function() M.new_note({ dir = cfg.zk_path,       tags = { 'zettel' },   prompt = 'Zettel title: ' }) end,  'new zettel' },
        { '<leader>onp', function() M.new_note({ dir = cfg.projects_path, tags = { 'projects' }, prompt = 'Project title: ' }) end, 'new project note' },
        { '<leader>onw', function() M.new_note({ dir = cfg.work_path,     tags = { 'work' },     prompt = 'Work title: ' }) end,    'new work note' },
    }
    for _, m in ipairs(maps) do
        vim.keymap.set('n', m[1], m[2], { desc = m[3], buffer = buf })
    end
end

--- Idempotent setup. Resolves config every call; wires autocmds and
--- keymaps exactly once. Safe to call from anywhere; intended location
--- is the user's plugin loader at top level.
--- @param opts table? user overrides for `kiser.obsidian.Config` fields
function M.setup(opts)
    _cfg = config.resolve(opts)
    if _wired then return end
    _wired = true

    local cfg = _cfg
    local patterns = { cfg.vault_root .. '/**.md', 'oil://' .. cfg.vault_root .. '/*' }
    local group = vim.api.nvim_create_augroup('kiser_obsidian', { clear = true })

    -- Conceallevel is owned by markview / FileType handlers; we don't fight
    -- those. The previous setup tried to set it here and lost the race anyway.
    vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
        group = group, pattern = patterns,
        callback = function(args) buf_keymaps(args.buf, cfg) end,
    })
end

return M
