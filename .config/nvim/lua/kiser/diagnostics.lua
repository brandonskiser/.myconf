--- @type 'buf' | 'all' | nil
local diagnostics_mode = nil

local function qflist_open()
    return vim.iter(vim.fn.getwininfo()):any(function(w) return w.quickfix == 1 end)
end

local function sort_by_severity(diagnostics)
    table.sort(diagnostics, function(a, b)
        return (a.severity or 5) < (b.severity or 5)
    end)
    return diagnostics
end

local function refresh_qflist()
    if not diagnostics_mode then return end
    local diagnostics = diagnostics_mode == 'all' and vim.diagnostic.get() or vim.diagnostic.get(0)
    vim.fn.setqflist(vim.diagnostic.toqflist(sort_by_severity(diagnostics)))
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
    vim.fn.setqflist(vim.diagnostic.toqflist(sort_by_severity(diagnostics)))
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
