local M = {}

local keymap_opts_defaults = {
    noremap = true,
    silent = true,
}

M.keymap_opts_with_desc = function(desc)
    return vim.tbl_deep_extend("force", { desc = desc }, keymap_opts_defaults)
end

M.keymap_opts_with_defaults = function(opts)
    if type(opts) == 'string' then
        return vim.tbl_deep_extend("force", { desc = opts }, keymap_opts_defaults)
    end

    return vim.tbl_deep_extend("force", opts, keymap_opts_defaults)
end

return M
