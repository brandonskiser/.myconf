-- User command and keymap for opening a floating window
-- of buffers that I can move to or wipeout.

local floating_win_open = false
local use_full_absolute_path = true

vim.api.nvim_create_user_command('BuflistOpenWin', function()
    if floating_win_open then return end

    -- Open a scratch buffer that is wiped when closed.
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    ---Returns a sorted array of strings of the form: "{buffer name} | {buffer id}",
    --only including buffers with names (ie, buffers associated with a file name)
    --and buflisted == true.
    ---@return string[]
    local function get_buf_names()
        -- Get list of buffer handles.
        local bufs = vim.api.nvim_list_bufs()
        local buf_names = {}
        for _, v in pairs(bufs) do
            local fname = vim.api.nvim_buf_get_name(v)
            if fname ~= '' and vim.bo[v].buflisted then
                -- Append the buffer name along with its id.
                buf_names[#buf_names + 1] = fname .. ' | ' .. tostring(v)
            end
        end
        table.sort(buf_names)
        return buf_names
    end

    ---Gets the buffer id from the line under the current cursor position.
    ---@param win integer
    ---@return number?
    local function get_buf_under_cursor(win)
        -- Get the line from the current cursor position.
        local pos = vim.api.nvim_win_get_cursor(win)
        local line = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false)[1]
        -- Parse the buffer id from the line.
        local idx = line:find('|')
        if idx == nil then return end
        return tonumber(line:sub(idx + 2, -1))
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, get_buf_names())
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)

    local width = vim.api.nvim_get_option('columns')
    local height = vim.api.nvim_get_option('lines')
    local win_width = math.ceil(width * 0.8)
    local win_height = math.ceil(height * 0.8 - 4)
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)
    local opts = {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = 'rounded'
    }
    local prev_win = vim.api.nvim_get_current_win()
    local floating_win = vim.api.nvim_open_win(buf, true, opts)
    floating_win_open = true

    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
        buffer = buf,
        callback = function()
            vim.api.nvim_win_close(floating_win, true)
            floating_win_open = false
            return true
        end
    })

    -- Floating window local keymaps.

    -- Open buffer under cursor on enter.
    vim.keymap.set('n', '<CR>', function()
        local buf_under_cursor = get_buf_under_cursor(floating_win)
        if buf_under_cursor == nil then return end
        vim.api.nvim_win_set_buf(prev_win, buf_under_cursor)
        vim.api.nvim_win_close(floating_win, true)
    end, { buffer = buf })

    -- Delete buffer on 'x'.
    vim.keymap.set('n', 'x', function()
        vim.api.nvim_buf_set_option(buf, 'modifiable', true)

        -- Get the line from the current cursor position.
        local pos = vim.api.nvim_win_get_cursor(floating_win)
        local line = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false)[1]
        -- Parse the buffer id from the line.
        local idx = line:find('|')
        if idx == nil then return end
        local buf_under_cursor = get_buf_under_cursor(floating_win)

        -- Using bufdelete to delete the buffer since the normal api doesn't
        -- really work for some reason. Need to use wipeout instead of delete
        -- to "really delete the buffer"
        require('bufdelete').bufwipeout(buf_under_cursor, false)

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, get_buf_names())

        vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    end, { buffer = buf })

    -- Close floating window on 'q'.
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(floating_win, true)
    end, { buffer = buf })
end, {})

vim.keymap.set('n', '<leader>lb', ':BuflistOpenWin<CR>', { desc = 'open buffer list' })
-- vim.api.nvim_set_keymap('n', '<leader>lb', ':BuflistOpenWin<CR>', opts)
