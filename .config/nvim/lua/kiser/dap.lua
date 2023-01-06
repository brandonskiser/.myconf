-- TODO: nvim-dap isn't working, or I just don't know how to use it yet.

local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

keymap("n", "<F5>", ":DapContinue<CR>", opts)
keymap("n", "<F10>", ":DapStepOver<CR>", opts)
keymap("n", "<F11>", ":DapStepInto<CR>", opts)
keymap("n", "<F12>", ":DapStepOut<CR>", opts)
keymap("n", "<leader>db", ":DapToggleBreakpoint<CR>", opts)

-- Debug Adapters are managed by Mason, see :h mason-default-settings for the
-- default installation path.
local install_path = function(executable)
    return vim.fn.stdpath("data") .. "/mason/" .. executable
end

-- See: https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation
local dap  = require("dap")
require("dapui").setup {}

dap.set_log_level("TRACE")

-- See: :h dap-adapter
dap.adapters.codelldb = {
    type = "server",
    port = "${port}", -- "${port}" will resolve a free port.
    executable = {
        command = install_path("codelldb"),
        args = { "--port", "${port}" }
    }
}

-- See: :h dap-configuration
dap.configurations.c = {
    name = "C launch file",
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
    end,
    cwd = '${workspaceFolder}',
}

