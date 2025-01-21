-- User command and keymap for opening a floating window
-- of buffers that I can move to or wipeout.

local M = {}

local state = {
    ---Whether or not the floating window is open.
    floating_win_open = false,
    ---Window id of the window just before the floating window was opened.
    prev_win = -1,
    ---Window id of the floating window.
    floating_win = -1,
    ---Buffer id of the floating window buffer.
    buf = -1,
}
-- local floating_win_open = false
-- local use_full_absolute_path = true

---Returns a sorted array of strings of the form: `"{buffer name} | {buffer id}"`,
--only including buffers with names (ie, buffers associated with a file name)
--and `buflisted == true`.
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
local function get_buf_under_cursor(win, buf)
    -- Get the line from the current cursor position.
    local pos = vim.api.nvim_win_get_cursor(win)
    local line = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false)[1]
    -- Parse the buffer id from the line.
    local idx = line:find('|')
    if idx == nil then return end
    return tonumber(line:sub(idx + 2, -1))
end

---Sets the buffer keymaps according to the current state.
local function set_local_keymaps()
    local prev_win, floating_win, buf = state.prev_win, state.floating_win, state.buf

    -- Open buffer under cursor on enter.
    vim.keymap.set('n', '<CR>', function()
        local buf_under_cursor = get_buf_under_cursor(floating_win, buf)
        if buf_under_cursor == nil then return end
        vim.api.nvim_win_set_buf(prev_win, buf_under_cursor)
        vim.api.nvim_win_close(floating_win, true)
    end, { buffer = buf })

    -- Delete buffer on 'x'.
    vim.keymap.set('n', 'x', function()
        vim.bo[buf].modifiable = true

        -- Get the line from the current cursor position.
        local pos = vim.api.nvim_win_get_cursor(floating_win)
        local line = vim.api.nvim_buf_get_lines(buf, pos[1] - 1, pos[1], false)[1]
        -- Parse the buffer id from the line.
        local idx = line:find('|')
        if idx == nil then return end
        local buf_under_cursor = get_buf_under_cursor(floating_win, buf)

        -- Using bufdelete to delete the buffer since the normal api doesn't
        -- really work for some reason. Need to use wipeout instead of delete
        -- to "really delete the buffer"
        require('bufdelete').bufwipeout(buf_under_cursor, false)

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, get_buf_names())
        vim.bo[buf].modifiable = false
    end, { buffer = buf })

    -- Close floating window on 'q'.
    vim.keymap.set('n', 'q', function()
        vim.api.nvim_win_close(floating_win, true)
    end, { buffer = buf })
end


vim.api.nvim_create_user_command('BuflistOpenWin', function()
    if state.floating_win_open then return end

    -- Open a scratch buffer that is wiped when closed.
    local buf = vim.api.nvim_create_buf(false, true)
    state.buf = buf
    vim.bo[buf].bufhidden = 'wipe'

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, get_buf_names())
    vim.bo[buf].modifiable = false

    local width = vim.api.nvim_get_option_value('columns', {})
    local height = vim.api.nvim_get_option_value('lines', {})
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
    state.prev_win = vim.api.nvim_get_current_win()
    state.floating_win = vim.api.nvim_open_win(buf, true, opts)
    state.floating_win_open = true

    vim.api.nvim_create_autocmd({ 'BufLeave' }, {
        buffer = buf,
        callback = function()
            vim.api.nvim_win_close(state.floating_win, true)
            state.floating_win_open = false
            return true
        end
    })

    set_local_keymaps()
end, {})

vim.keymap.set('n', '<leader>lb', ':BuflistOpenWin<CR>', { desc = 'open buffer list' })

return M
