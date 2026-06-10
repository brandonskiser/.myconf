--- Plain-table configuration. Defaults target the user's existing vault
--- layout under `~/vaults/{personal,work}`. `setup({...})` accepts any
--- subset of these keys to override.

local M = {}

local VAULT = vim.fn.expand('~/vaults')

--- @class kiser.obsidian.Config
--- @field vault_root string             -- absolute root containing all workspaces
--- @field workspaces string[]           -- absolute paths to workspace roots
--- @field zk_path string                -- target dir for `<leader>onz` (zettel)
--- @field projects_path string          -- target dir for `<leader>onp` (project)
--- @field work_path string              -- target dir for `<leader>onw` (work)
--- @field templates_dir string          -- basename of the templates directory
--- @field exclude_dirs string[]         -- dir basenames excluded from index/pickers

--- @type kiser.obsidian.Config
M.defaults = {
    vault_root = VAULT,
    workspaces = {
        vim.fs.joinpath(VAULT, 'personal'),
        vim.fs.joinpath(VAULT, 'work'),
    },
    zk_path = vim.fs.joinpath(VAULT, 'personal', 'zk'),
    projects_path = vim.fs.joinpath(VAULT, 'personal', 'projects'),
    work_path = vim.fs.joinpath(VAULT, 'work'),
    templates_dir = '_templates',
    exclude_dirs = { '_templates' },
}

--- Merge user-supplied opts over the defaults. Keys not present in opts
--- fall through to the defaults.
--- @param opts table?  partial overrides for `kiser.obsidian.Config`
--- @return kiser.obsidian.Config
function M.resolve(opts)
    return vim.tbl_deep_extend('force', M.defaults, opts or {})
end

--- True when `path` lives strictly under the vault root. Path-segment
--- aware so `~/vaults_other` does NOT match `~/vaults`.
--- @param cfg kiser.obsidian.Config
--- @param path string?  buffer name or absolute path; nil/empty -> false
--- @return boolean
function M.is_in_vault(cfg, path)
    if path == nil or path == '' then return false end
    local abs = vim.fn.fnamemodify(path, ':p')
    local root = cfg.vault_root
    return abs == root or vim.startswith(abs, root .. '/')
end

return M
