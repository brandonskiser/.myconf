vim.pack.add({
    { src = gh('nvim-lua/plenary.nvim') },
    {
        src = gh('olimorris/codecompanion.nvim'),
        version = vim.version.range('^18.0.0'),
    },
})

local helpers = require("codecompanion.adapters.acp.helpers")

---@type CodeCompanion.ACPAdapter
local kiro_adapter = {
    -- Internal identifier for the adapter
    name = "kiro",
    -- Display name shown in UI
    formatted_name = "Kiro",
    -- Adapter protocol type (either "http" or "acp")
    type = "acp",
    -- Maps codecompanion roles to the agent's expected role names
    roles = {
        llm = "assistant",
        user = "user",
    },
    -- Feature flags for the adapter
    opts = {
        vision = true, -- Whether the agent supports image inputs
    },
    -- Command(s) to spawn the ACP agent process
    commands = {
        default = {
            "/Volumes/workplace/kiro-cli-chat-dev/target/debug/chat_cli",
            "acp",
        },
    },
    -- Default configuration values
    defaults = {
        mcpServers = {}, -- MCP servers to connect to
        timeout = 20000, -- Request timeout in ms
    },
    -- Environment variables to pass to the agent (key = var name, value = source)
    env = {},
    -- ACP protocol parameters sent during initialization
    parameters = {
        protocolVersion = 1,
        clientCapabilities = {
            fs = { readTextFile = true, writeTextFile = true },
        },
        clientInfo = {
            name = "CodeCompanion.nvim",
            version = "1.0.0",
        },
    },
    handlers = {
        -- Called once when adapter is first used; return true to proceed
        setup = function(self) return true end,
        -- Handle authentication; return true if auth succeeded or not needed
        auth = function(self) return true end,
        -- Transform codecompanion messages into ACP message format
        form_messages = function(self, messages, capabilities)
            return helpers.form_messages(self, messages, capabilities)
        end,
        -- Called when the agent process exits
        on_exit = function(self, code) end,
    },
}

local setup_ran = false

local function code()
    local cc = require('codecompanion')
    if not setup_ran then
        cc.setup({
            adapters = {
                acp = {
                    kiro = kiro_adapter,
                },
            },
            strategies = {
                chat = { adapter = "kiro" },
                inline = { adapter = "kiro" },
            },
            display = {
                chat = {
                    window = {}
                }
            }
        })
        setup_ran = true
    end
    return cc
end

vim.keymap.set('n', '<C-a>', function()
    code().toggle()
end, { noremap = true, desc = 'open code companion' })

vim.keymap.set('n', '<leader><C-a>', function()
    code().actions({})
end, { noremap = true, desc = 'code companion actions' })
