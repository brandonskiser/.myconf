return {
    'akinsho/bufferline.nvim',
    lazy = false,
    dependencies = {
        'nvim-tree/nvim-web-devicons'
    },
    opts = {
        options = {
            -- separator_style = "slant",
            diagnostics = "nvim_lsp",
            --- count is an integer representing total count of errors
            --- level is a string "error" | "warning"
            --- diagnostics_dict is a dictionary from error level ("error", "warning" or "info")to number of errors for each level.
            --- this should return a string
            --- Don't get too fancy as this function will be executed a lot
            -- diagnostics_indicator = function(count, level, diagnostics_dict, context)
            --     local icon = level:match("error") and " " or " "
            --     return " " .. icon .. count
            -- end
        }
    },
    keys = function()
        local keys = {
            { '<leader>bg', '<cmd>BufferLinePick<CR>', desc = 'go to buffer' },
            { '<leader>bc', '<cmd>BufferLinePickClose<CR>', desc = 'pick buffer to close' },
            { '<S-Left>', '<cmd>BufferLineMovePrev<CR>', desc = 'move buffer left' },
            { '<S-Right>', '<cmd>BufferLineMoveNext<CR>', desc = 'move buffer right' },

            -- VScode type navigation (doesn't work since termiinals don't support ctrl + page up/down)
            -- { '<C-PageUp>', '<cmd>BufferLineCyclePrev<CR>' },
            -- { '<C-PageDown>', '<cmd>BufferLineCycleNext<CR>' },
            -- { '<C-PageUp>', '<C-o><cmd>BufferLineCyclePrev<CR>', mode = { 'i' } },
            -- { '<C-PageDown>', '<C-o><cmd>BufferLineCycleNext<CR>', mode = { 'i' } },
        }
        for i = 1, 9 do
            keys[#keys+1] = { '<leader>' .. tostring(i), '<cmd>BufferLineGoToBuffer ' .. tostring(i) .. '<CR>' }
        end
        return keys
    end
}