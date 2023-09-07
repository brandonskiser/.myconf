-- Resources:
-- https://vimways.org/2019/personal-notetaking-in-vim/ | https://www.reddit.com/r/vim/comments/ej3wzp/vimways_2019_personal_notetaking_in_vim/
--
-- Telekasten: https://github.com/renerocksai/telekasten.nvim/wiki/Features-Overview
-- highlights - search by tag, focus on Telescope
--
-- Zettelkasten: https://github.com/Furkanzmc/zettelkasten.nvim/wiki
-- highlights - use vim builtins as much as possible - ctags

local M = {}

function M.get_zettel_name(id)
    if not id:match('.md$') then
        id = id .. '.md'
    end

    local name = vim.fn.system('head -n 1 ' .. id .. " | tr -d '\n' | sed 's/^#[[:space:]]//'", nil)
    return name
end

function M.new_zettel()
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'markdown',
    callback = function()
        vim.opt_local.suffixesadd:append { '.md' }
    end
})

vim.api.nvim_create_autocmd('BufRead', {
    pattern = '*/wiki/*.md',
    callback = function(ev)
        -- Required to support '/' and '-' in zettel id's
        vim.opt_local.iskeyword:append { '/', '-' }

        vim.api.nvim_buf_create_user_command(ev.buf, 'ZtlViewName', function(thing)
            -- vim.notify(vim.inspect(thing))
            if #thing.fargs ~= 1 then 
                vim.notify('Expected 1 argument, got: ' .. thing.args)
                return
            end
            local name = M.get_zettel_name(thing.fargs[1])
            vim.lsp.util.open_floating_preview({ name }, '', {})
        end, {
            nargs = '*'
        })

        vim.opt_local.keywordprg = ':ZtlViewName'
    end
})

return M
