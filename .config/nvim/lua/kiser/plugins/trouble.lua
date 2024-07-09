return {
    'folke/trouble.nvim',
    cmd = "Trouble",
    keys = {
        {
            '<leader>dt', '<cmd>Trouble diagnostics toggle<CR>', desc = 'toggle trouble'
        },
        {
            '<leader>dT', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', desc = 'toggle trouble for buffer'
        }
    },
    opts = {},
}
