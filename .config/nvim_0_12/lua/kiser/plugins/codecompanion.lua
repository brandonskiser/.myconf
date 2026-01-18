vim.pack.add({
    { src = gh('nvim-lua/plenary.nvim') },
    {
        src = gh('olimorris/codecompanion.nvim'),
        version = vim.version.range('^18.0.0'),
    },
})

local setup_ran = false

local function code()
    local cc = require('codecompanion')
    if not setup_ran then
        cc.setup({
            display = {
                chat = {
                    window = {
                        -- width = 0.3
                    }
                }
            }
        })
    end
    return cc
end

vim.keymap.set('n', '<C-a>', function()
    code().toggle()
end, { noremap = true, desc = 'open code companion' })
