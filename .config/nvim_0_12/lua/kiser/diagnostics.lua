--- @type 'buf' | 'all' | nil
local diagnostics_open_state = nil

local qflist_open = function()
    return vim.iter(vim.fn.getwininfo()):any(function(wininf) return wininf.quickfix == 1 end)
end

local open_all_diagnostics = function()
    local diagnostics = vim.diagnostic.get()
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    table.sort(diagnostics, function(a, b) return a.severity > b.severity end)
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
end

local open_buf_diagnostics = function()
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    table.sort(diagnostics, function(a, b) return a.severity > b.severity end)
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
end


vim.keymap.set('n', '<leader>dt', function()
    if diagnostics_open_state == 'all' then
        vim.cmd('cclose')
        return
    end
    local diagnostics = vim.diagnostic.get()
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
end, { noremap = true })

vim.keymap.set('n', '<leader>dT', function()
    if diagnostics_open_state == 'buf' then
        vim.cmd('cclose')
        return
    end
    local diagnostics = vim.diagnostic.get(0)
    if #diagnostics == 0 then
        vim.notify('No diagnostics')
        return
    end
    local ds = vim.diagnostic.toqflist(diagnostics)
    vim.fn.setqflist(ds)
    vim.cmd('copen')
end, { noremap = true })

vim.api.nvim_create_autocmd('DiagnosticChanged', {
    callback = function(args)
        -- todo - refresh
    end
})

--[[
-- Create an autocommand group for organization (recommended)
local qf_group = vim.api.nvim_create_augroup("MyQuickfixGroup", { clear = true })

-- Define the autocommand to run after any Quickfix command
vim.api.nvim_create_autocmd("QuickfixCmdPost", {
  group = qf_group,
  callback = function()
    print("Quickfix command finished!") -- Or any other command like :cclose, :lopen, etc.
    -- vim.cmd("echo 'Quickfix done!'")
    -- vim.notify("QF done", vim.log.levels.INFO)
  end,
  desc = "Run something after Quickfix operations",
})

-- Example: Close the qf window automatically after :make or :grep finishes
vim.api.nvim_create_autocmd("QuickfixCmdPost", {
  group = qf_group,
  pattern = "make,grep,vimgrep", -- Specific commands to trigger on
  callback = function()
    if vim.fn.getwininfo(vim.w.quickfix_winid)[1].height > 0 then -- Check if qf window is open
      vim.cmd("cclose")
    end
  end,
})
]]
