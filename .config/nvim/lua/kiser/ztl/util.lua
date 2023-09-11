local M = {}

M.ztl_dirname = vim.fn.expand('~/wiki/')

M.build_tagslist_index_fname = M.ztl_dirname .. 'build-tagslist-index.sh'
M.tagslist_index_fname = M.ztl_dirname .. '.index-tagslist'

M.build_tags_index_fname = M.ztl_dirname .. 'build-tags-index.sh'
M.tags_index_fname = M.ztl_dirname .. '.index-tags'

M.build_names_index_fname = M.ztl_dirname .. 'build-names-index.sh'
M.names_index_fname = M.ztl_dirname .. '.index-names'

---Checks if the neovim cwd is in the zettelkasten directory
---@return boolean
function M.in_wiki()
    return M.ztl_dirname:match(vim.fn.getcwd())
end

---Returns 'filename | title'
---@return string
function M.print_id_and_name()
    return vim.fn.system(M.find_filename_and_title_cmd)
end

---Returns the title of the zettel from its id.
--
--The id may or may not include the '.md' suffix
---@param id string
---@return string
function M.get_zettel_name(id)
    if not id:match('.md$') then
        id = id .. '.md'
    end
    local name = vim.fn.system('head -n 1 ' .. id .. " | tr -d '\n' | sed 's/^#[[:space:]]//'", nil)
    return name
end

return M
