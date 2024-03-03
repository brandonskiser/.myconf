local util = require('kiser.util')
local path = require('kiser.util.path')

local VAULT_PATH = vim.fn.expand('~/vaults')
local ZK_PATH = path.join(VAULT_PATH, 'personal', 'zk')

local function is_path_in_vault(path)
    return path ~= nil and path:match(VAULT_PATH)
end

return {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    event = {
        -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
        'BufReadPre ' .. VAULT_PATH .. '/**.md',
        'BufNewFile ' .. VAULT_PATH .. '/**.md',
        'BufReadPre ' .. 'oil://' .. VAULT_PATH .. '/*',
    },
    dependencies = {
        -- Required.
        'nvim-lua/plenary.nvim',

        -- Optional dependencies.
        'nvim-telescope/telescope.nvim',
        'nvim-treesitter/nvim-treesitter'
    },
    config = function(_, opts)
        require('obsidian').setup(opts)

        -- Set the conceallevel to 2 for markdown files in the vault.
        -- This is required to enable some special UI features.
        if is_path_in_vault(vim.api.nvim_buf_get_name(0)) then
            vim.opt_local.conceallevel = 2
        end
        vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
            pattern = { '*.md' },
            callback = function(ev)
                local bufpath = ev.match
                if is_path_in_vault(bufpath) then
                    vim.opt_local.conceallevel = 2
                end
            end
        })

        local keymaps = {
            { '<leader>os',  ':ObsidianSearch<CR>',        desc = 'obsidian search' },
            { '<leader>oS',  ':ObsidianSearch ',           desc = 'obsidian search with initial search term' },
            { '<leader>ot',  ':ObsidianTags<CR>',          desc = 'obsidian tags' },
            { '<leader>ob',  ':ObsidianBacklinks<CR><CR>', desc = 'obsidian backlinks' },
            { '<leader>ofl', ':ObsidianFollowLink<CR>',    desc = 'obsidian follow link' },
            { 'gd',          ':ObsidianFollowLink<CR>',    desc = 'obsidian follow link' },
            { '<leader>oo',  ':ObsidianOpen<CR>',          desc = 'obsidian open' }
        }
        for _, keymap in ipairs(keymaps) do
            vim.keymap.set('n', keymap[1], keymap[2], { desc = keymap.desc })
        end

        -- Create a new Zettel.
        vim.keymap.set('n', '<leader>onz', function()
            local client = require('obsidian').get_client()
            local title = vim.fn.input('Enter name: ')
            if title == '' then
                print('No name provided, not creating note.')
                return
            end
            local id = client:new_note_id(title)
            local note = client:create_note({
                id = id,
                title = title,
                aliases = { title },
                dir = ZK_PATH,
                tags = { 'zettel' }
            })
            client:open_note(note)
        end, { desc = 'new zettel' })
    end,
    opts = {
        workspaces = {
            {
                name = 'personal',
                path = '~/vaults/personal',
            },
            {
                name = 'work',
                path = '~/vaults/work',
            },
        },

        -- Default should open a zettelkasten note.
        notes_subdir = 'zk',

        daily_notes = {
            folder = 'dailies'
        },

        note_id_func = function(title)
            local suffix = ''
            if title ~= nil then
                -- If title is given, transform it into valid file name.
                suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
            else
                -- If title is nil, just add 4 random uppercase letters to the suffix.
                for _ = 1, 4 do
                    suffix = suffix .. string.char(math.random(65, 90))
                end
            end
            -- Get a timestamp ISO-8601 UTC style, except remove colons
            -- to make it file name friendly.
            -- TODO: test on Mac, prob change cmd on Mac to use gnu utils instead.
            local ts = vim.fn.system('date -u --iso-8601=seconds'):gsub(':', '')
            ts = ts:sub(0, ts:find('+') - 1) .. 'Z'
            return ts .. "_" .. suffix
        end,

        -- note_frontmatter_func = function(note)
        --     print('Inspecting...')
        --     print(vim.inspect(note))
        --     if note.title then
        --         note:add_alias(note.title)
        --     end
        --     local out = {
        --         id = note.id,
        --         aliases = note.aliases,
        --         tags = note.tags
        --     }
        --     -- `note.metadata` contains any manually added fields in the frontmatter.
        --     -- So here we just make sure those fields are kept in the frontmatter.
        --     if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        --         for k, v in pairs(note.metadata) do
        --             out[k] = v
        --         end
        --     end
        --     return out
        -- end,

        follow_url_func = function(url)
            -- Open the URL in the default web browser.
            if util.os.is_mac() then
                vim.fn.jobstart({ 'open', url })
            else
                vim.fn.jobstart({ 'xdg-open', url })
            end
        end,

        templates = {
            subdir = '_templates'
        },

        -- Optional, sort search results by "path", "modified", "accessed", or "created".
        -- The recommend value is "modified" and `true` for `sort_reversed`, which means, for example,
        -- that `:ObsidianQuickSwitch` will show the notes sorted by latest modified time
        sort_by = "modified",
        sort_reversed = true,
    },
}
