--- @type 'buf' | 'all' | nil
local diagnostics_mode = nil

local function qflist_open()
    return vim.iter(vim.fn.getwininfo()):any(function(w) return w.quickfix == 1 end)
end

-- vim.diagnostic.toqflist() re-sorts items by bufnr/lnum/col, discarding any
-- ordering of the input. Sort the converted qf items instead, using the `type`
-- field ('E' < 'W' < 'I' < 'N') so that errors surface at the top.
local qf_type_rank = { E = 1, W = 2, I = 3, N = 4 }

--- @param diagnostics vim.Diagnostic[]
--- @return vim.quickfix.entry[]
local function to_sorted_qflist(diagnostics)
    local items = vim.diagnostic.toqflist(diagnostics)
    table.sort(items, function(a, b)
        local ra, rb = qf_type_rank[a.type] or 5, qf_type_rank[b.type] or 5
        if ra ~= rb then return ra < rb end
        if a.bufnr ~= b.bufnr then return a.bufnr < b.bufnr end
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.col < b.col
    end)
    return items
end

local function refresh_qflist()
    if not diagnostics_mode then return end
    local diagnostics = diagnostics_mode == 'all' and vim.diagnostic.get() or vim.diagnostic.get(0)
    vim.fn.setqflist(to_sorted_qflist(diagnostics))
end

local function toggle_diagnostics(mode)
    if diagnostics_mode == mode then
        vim.cmd('cclose')
        return
    end
    local diagnostics = mode == 'all' and vim.diagnostic.get() or vim.diagnostic.get(0)
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    vim.fn.setqflist(to_sorted_qflist(diagnostics))
    diagnostics_mode = mode
    vim.cmd('copen')
end

vim.keymap.set('n', '<leader>dt', function() toggle_diagnostics('all') end)
vim.keymap.set('n', '<leader>dT', function() toggle_diagnostics('buf') end)

vim.api.nvim_create_autocmd('DiagnosticChanged', {
    callback = refresh_qflist,
})

vim.api.nvim_create_autocmd('WinClosed', {
    callback = function()
        -- WinClosed fires before window is removed; schedule to check after
        -- so that window state from getwininfo() is up to date
        vim.schedule(function()
            if not qflist_open() then diagnostics_mode = nil end
        end)
    end,
})
