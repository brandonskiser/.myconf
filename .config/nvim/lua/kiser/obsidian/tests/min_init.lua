-- Minimal init for running kiser.obsidian tests headlessly.
-- Usage: nvim --headless --clean -u lua/kiser/obsidian/tests/min_init.lua \
--                +"lua MiniTest.run()" +"qa!"
-- Or to run a single file:
-- nvim --headless --clean -u lua/kiser/obsidian/tests/min_init.lua \
--   +"lua MiniTest.run_file('lua/kiser/obsidian/tests/frontmatter_spec.lua')" +"qa!"

-- Locate this config root (lua/kiser/obsidian/tests/min_init.lua -> ../../../..)
local this = debug.getinfo(1, 'S').source:sub(2)
local config_root = vim.fn.fnamemodify(this, ':p:h:h:h:h:h')

-- Add config root to runtimepath so `require('kiser.obsidian.*')` works.
vim.opt.runtimepath:prepend(config_root)

-- `--clean` blanks packpath, hiding the user's already-installed plugins.
-- Re-add the data-dir site path so vim.pack.add can find existing installs
-- of mini.pick/mini.extra (and the freshly-installed mini.test) instead of
-- erroring with E919.
local site = vim.fn.stdpath('data') .. '/site'
vim.opt.packpath:prepend(site)

-- Install only the plugins the test suite needs.
vim.pack.add({
    { src = 'https://github.com/nvim-mini/mini.pick' },
    { src = 'https://github.com/nvim-mini/mini.extra' },
    { src = 'https://github.com/nvim-mini/mini.test' },
})

require('mini.test').setup({
    collect = {
        find_files = function()
            return vim.fn.globpath(
                config_root .. '/lua/kiser/obsidian/tests',
                '*_spec.lua',
                true,
                true
            )
        end,
    },
})
