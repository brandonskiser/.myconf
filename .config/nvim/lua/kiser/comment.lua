local ok, comment = pcall(require, "Comment")
if not ok then
    print("unable to require Comment")
    return
end

-- default config: https://github.com/numToStr/Comment.nvim#configuration-optional
-- also see for default key mappings: https://github.com/numToStr/Comment.nvim#basic-mappings
comment.setup {
    pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    -- LHS of toggle mappings in NORMAL mode
    toggler = {
        -- Line-comment toggle keymap
        line = '<leader>cc',
        -- Block-comment toggle keymap
        block = '<leader>Cc',
    },
    -- LHS of operator-pending mappings in NORMAL and VISUAL mode
    opleader = {
        -- Line-comment keymap
        line = '<leader>c',
        -- Block-comment keymap
        block = '<leader>C',
    },
    mappings = {
        basic = true,
        extra = true, -- extra key mappings (e.g., gco, gcO, gcA) don't use <leader>c prefix
    },
}

-- Examples
-- # Linewise

-- `<leader>cw` - Toggle from the current cursor position to the next word
-- `<leader>c$` - Toggle from the current cursor position to the end of line
-- `<leader>c}` - Toggle until the next blank line
-- `<leader>c5j` - Toggle 5 lines after the current cursor position
-- `<leader>c8k` - Toggle 8 lines before the current cursor position
-- `<leader>cip` - Toggle inside of paragraph
-- `<leader>ca}` - Toggle around curly brackets
