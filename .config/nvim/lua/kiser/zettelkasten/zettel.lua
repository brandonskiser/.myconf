local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require 'telescope.config'.values

-- logs are saved to ~/.cache/nvim/[plugin-name].log
local log = require('plenary.log').new {
    plugin = 'zettelkasten',
    level = 'info',
}

local zettel_dir = os.getenv('ZTL_DIR')

if not zettel_dir then
    print 'ZTL_DIR environment variable not set'
    -- return
end

if not vim.fn.executable('ztl') then
    print 'ztl command is missing'
    -- return
end


local zettelkasten = function(opts)
    local opts = opts or {}
    local ztl_cmd = { 'ls' }

    local my_entry_maker = function(entry)
        return {
            value = entry,
            ordinal = entry,
            display = '???' .. entry
        }
    end

    local my_finder = finders.new_job(function(prompt)
        log.trace('Got prompt: ' .. prompt)
        return { 'ls' }
    end, my_entry_maker, _, opts.cwd or vim.fn.getcwd())

    pickers
        .new(opts, {
            prompt_title = 'Zettelkasten',
            finder = my_finder,
            sorter = conf.generic_sorter(opts),
            -- finder = finders.new_oneshot_job(ztl_cmd, opts)
        })
        :find()
end

zettelkasten()
