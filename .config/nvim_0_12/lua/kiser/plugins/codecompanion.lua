local chat_cli = "/Volumes/workplace/kiro-cli-chat-dev/target/debug/chat_cli"
local setup_ran = false

local function setup()
    vim.pack.add({
        gh('nvim-lua/plenary.nvim'),
        { src = gh('olimorris/codecompanion.nvim'), version = vim.version.range('^18.0.0') },
    })

    local opts = {
        display = { chat = { window = {} } },
    }

    if vim.uv.fs_stat(chat_cli) then
        local helpers = require("codecompanion.adapters.acp.helpers")
        opts.adapters = {
            acp = {
                kiro = {
                    name = "kiro",
                    formatted_name = "Kiro",
                    type = "acp",
                    roles = { llm = "assistant", user = "user" },
                    opts = { vision = true },
                    commands = { default = { chat_cli, "acp" } },
                    defaults = { mcpServers = {}, timeout = 20000 },
                    env = {},
                    parameters = {
                        protocolVersion = 1,
                        clientCapabilities = { fs = { readTextFile = true, writeTextFile = true } },
                        clientInfo = { name = "CodeCompanion.nvim", version = "1.0.0" },
                    },
                    handlers = {
                        setup = function(self) return true end,
                        auth = function(self) return true end,
                        form_messages = function(self, messages, capabilities)
                            return helpers.form_messages(self, messages, capabilities)
                        end,
                        on_exit = function(self, _) end,
                    },
                },
            },
        }
        opts.strategies = {
            chat = { adapter = "kiro" },
            inline = { adapter = "kiro" },
        }
    end

    require('codecompanion').setup(opts)
end

local function code()
    if not setup_ran then
        setup()
        setup_ran = true
    end
    return require('codecompanion')
end

vim.keymap.set('n', '<C-a>', function()
    code().toggle()
end, { noremap = true, desc = 'open code companion' })

vim.keymap.set('n', '<leader><C-a>', function()
    code().actions({})
end, { noremap = true, desc = 'code companion actions' })
