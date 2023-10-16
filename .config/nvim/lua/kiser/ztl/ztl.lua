-- Resources:
-- https://vimways.org/2019/personal-notetaking-in-vim/ | https://www.reddit.com/r/vim/comments/ej3wzp/vimways_2019_personal_notetaking_in_vim/
--
-- Telekasten: https://github.com/renerocksai/telekasten.nvim/wiki/Features-Overview
-- highlights - search by tag, focus on Telescope
--
-- Zettelkasten: https://github.com/Furkanzmc/zettelkasten.nvim/wiki
-- highlights - use vim builtins as much as possible - ctags

local M = {}

local util = require('kiser.ztl.util')


vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        vim.opt_local.suffixesadd:append { '.md' }
    end
})

-- Creates a new zettel.
--
-- Accepts one optional argument to act as the prefix, e.g. ':Ztl work'
-- will create a new zettel 'work/{ZETTEL_ID}.md'
vim.api.nvim_create_user_command('Ztl', function(cb)
    local fname = util.ztl_dirname
    if #cb.fargs > 0 then
        fname = fname .. cb.fargs[1] .. '/'
    end
    fname = fname .. vim.fn.strftime('%Y-%m-%d-%H%M%S.md')
    vim.cmd(':e ' .. fname)
end, { nargs = '*' })

vim.api.nvim_create_user_command('ZtlBuildIndex', function()
    vim.fn.system(util.build_tagslist_index_fname .. ' > ' .. util.tagslist_index_fname)
    vim.fn.system(util.build_tags_index_fname .. ' > ' .. util.tags_index_fname)
    vim.fn.system(util.build_names_index_fname .. ' > ' .. util.names_index_fname)
end, {})

-- If I want to support using tags with ctags, I guess
-- if vim.fn.executable('ctags') == 1 then
--     vim.api.nvim_create_user_command('ZtlCreateTags', function()
--         local cmd =
--         '!ctags -R --langdef=markdowntags --languages=markdowntags --langmap=markdowntags:.md --kinddef-markdowntags=t,tag,tags'
--         cmd = cmd .. " --mline-regex-markdowntags='/(^|[[:space:]])\\#(\\w\\S*)/\\2/t/{mgroup=1}'"
--         cmd = cmd .. ' .'
--         vim.cmd(cmd)
--     end, {})
-- end

vim.api.nvim_create_autocmd('BufRead', {
    pattern = '*/wiki/*.md',
    callback = function(ev)
        -- Required to support '/' and '-' in zettel id's.
        vim.opt_local.iskeyword:append { '/', '-' }

        -- Used by the 'K' command.
        vim.opt_local.keywordprg = ':ZtlViewName'

        vim.api.nvim_buf_create_user_command(ev.buf, 'ZtlViewName', function(args)
            if #args.fargs ~= 1 then
                vim.notify('Expected 1 argument, got: ' .. args.args)
                return
            end
            local name = util.get_zettel_name(args.fargs[1])
            vim.lsp.util.open_floating_preview({ name }, '', {})
        end, {
            nargs = '*'
        })

        -- Opens the tags index for the tag under the current cursor.
        vim.keymap.set('n', 'gd', function()
            local word = vim.fn.expand('<cWORD>')

            if not word:match('^#') then
                return
            end

            local buf = vim.api.nvim_create_buf(true, true)
            vim.api.nvim_win_set_buf(0, buf)

            local cmd = ":0r !grep "
            -- '#' is a keyword in Ex commands, so need to escape with fnameescape
            local grep_args = "'" .. vim.fn.fnameescape(word) .. "' " .. vim.fn.fnameescape(util.tags_index_fname)
            vim.cmd(cmd .. grep_args)
        end, { buffer = ev.buf })

        -- TODO: Get preview window working.
        vim.keymap.set('n', '<C-p>', function()
            local word = vim.fn.expand('<cWORD>')
            vim.notify(word)
            -- Match any text wrapped around double brackets - ie, [[MATCH_ME]]
            if word:match('^[[][[].*]]$') then
                vim.notify('matched')
                local fname = word:sub(3, word:len() - 2)
                vim.notify(fname)

                vim.notify(tostring(vim.api.nvim_win_get_number(0)))
                vim.cmd(':vsplit')
                vim.notify(tostring(vim.api.nvim_win_get_number(0)))
                -- local wins = vim.api.nvim_list_wins()
                -- local size = #wins
                -- vim.notify(vim.inspect(wins))
                -- vim.api.nvim_set_current_win(wins[size])
                -- vim.cmd(':e ' .. 'newthingy')
            end
        end, { buffer = ev.buf })
    end
})

return M
