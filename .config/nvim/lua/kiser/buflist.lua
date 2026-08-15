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
    ---Entries currently rendered in the floating window, indexed by line number.
    ---@type BuflistEntry[]
    entries = {},
}

---A single buffer shown in the floating window.
---@class BuflistEntry
---@field id integer Buffer id.
---@field path string Buffer file path; empty for nameless buffers.

---The label shown for a buffer that has no file name.
local NO_NAME_LABEL = "[No Name]"

---Builds the display line for an entry: `"{buffer name} | {buffer id}"`.
---@param entry BuflistEntry
---@return string
local function format_line(entry)
    local path = entry.path
    if path == "" then path = NO_NAME_LABEL end
    return path .. " | " .. tostring(entry.id)
end

---Fallback listing used when bufferline is unavailable: all `buflisted`
---buffers (including nameless ones), sorted alphabetically by path.
---@return BuflistEntry[]
local function get_bufs_fallback()
    local entries = {}
    for _, buf in pairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buflisted then
            entries[#entries + 1] = { id = buf, path = vim.api.nvim_buf_get_name(buf) }
        end
    end
    table.sort(entries, function(a, b) return a.path < b.path end)
    return entries
end

---Returns the buffers to display, mirroring bufferline's tabline exactly:
---same buffers (every `buflisted` buffer, including nameless ones) in the
---same order, honoring manual moves and custom sort. Falls back to an
---alphabetical scan if bufferline is not loaded.
---@return BuflistEntry[]
local function get_bufs()
    local ok, bufferline = pcall(require, "bufferline")
    if not ok then
        return get_bufs_fallback()
    end

    local entries = {}
    for _, el in ipairs(bufferline.get_elements().elements) do
        entries[#entries + 1] = { id = el.id, path = el.path }
    end
    return entries
end

---Refreshes `state.buf` with the current buffer list and caches the entries
---in `state.entries` so they can be looked up by line number.
---@return BuflistEntry[]
local function render_bufs()
    local entries = get_bufs()
    state.entries = entries

    local lines = {}
    for i, entry in ipairs(entries) do
        lines[i] = format_line(entry)
    end

    vim.bo[state.buf].modifiable = true
    vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
    vim.bo[state.buf].modifiable = false

    return entries
end

---Returns the entry on the line under the cursor of the given window.
---@param win integer
---@return BuflistEntry?
local function entry_under_cursor(win)
    local row = vim.api.nvim_win_get_cursor(win)[1]
    return state.entries[row]
end

---Reorders the buffer under the cursor within bufferline by `direction`
---(-1 up, +1 down), then re-renders and keeps the cursor on the moved buffer.
---No-op when bufferline is unavailable or the move would fall off either end.
---@param direction integer
local function move_entry(direction)
    local win = state.floating_win
    local row = vim.api.nvim_win_get_cursor(win)[1]
    local target = row + direction
    if target < 1 or target > #state.entries then return end

    local ok, bufferline = pcall(require, "bufferline")
    if not ok then return end

    local moved_id = state.entries[row].id
    bufferline.move_to(target, row)

    vim.cmd("redrawtabline")
    local entries = render_bufs()
    for i, entry in ipairs(entries) do
        if entry.id == moved_id then
            vim.api.nvim_win_set_cursor(win, { i, 0 })
            break
        end
    end
end

---Deletes the given buffers, then redraws bufferline and re-renders the list.
---@param ids integer[]
local function delete_buffers(ids)
    -- Deleting a buffer will close any windows open with that buffer, so
    -- buf_delete repoints those windows to another buffer before deleting.
    -- Falls back to a scratch buffer if no other file buffers exist.
    local buf_delete = require('kiser.util.nvim').buf_delete
    for _, id in ipairs(ids) do
        buf_delete(id)
    end

    -- bufferline only refreshes its component list when the tabline is
    -- redrawn, so force a redraw before re-reading it.
    vim.cmd("redrawtabline")
    render_bufs()
end

---Sets the buffer keymaps according to the current state.
local function set_local_keymaps()
    local prev_win, floating_win, buf = state.prev_win, state.floating_win, state.buf

    -- Open buffer under cursor on enter.
    vim.keymap.set("n", "<CR>", function()
        local entry = entry_under_cursor(floating_win)
        if entry == nil then return end
        vim.api.nvim_win_set_buf(prev_win, entry.id)
        vim.api.nvim_win_close(floating_win, true)
    end, { buffer = buf })

    -- Delete buffer under cursor on 'x'.
    vim.keymap.set("n", "x", function()
        local entry = entry_under_cursor(floating_win)
        if entry == nil then return end
        delete_buffers({ entry.id })
    end, { buffer = buf })

    -- Delete all buffers in the visual selection on 'x'.
    vim.keymap.set("x", "x", function()
        local first = vim.fn.line("v")
        local last = vim.fn.line(".")
        if first > last then first, last = last, first end

        -- Leave visual mode before mutating the buffer/list.
        --
        -- "nx" are the mode flags
        --   n = noremap: don't expand the fed keys through other mappings (avoid recursion/surprises).
        --   x = execute immediately: drain the typeahead now so the Esc is processed before this function returns,
        --       rather than queued for after. This is what makes it synchronous.
        vim.api.nvim_feedkeys(
            vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)

        -- Collect ids up front: each delete re-renders and re-indexes entries.
        local ids = {}
        for row = first, last do
            local entry = state.entries[row]
            if entry then ids[#ids + 1] = entry.id end
        end

        delete_buffers(ids)

        local row = math.min(first, #state.entries)
        if row >= 1 then
            vim.api.nvim_win_set_cursor(floating_win, { row, 0 })
        end
    end, { buffer = buf })

    -- Close floating window on 'q'.
    vim.keymap.set("n", "q", function()
        vim.api.nvim_win_close(floating_win, true)
    end, { buffer = buf })

    -- Reorder the buffer under the cursor within bufferline.
    vim.keymap.set("n", "<A-j>", function() move_entry(1) end, { buffer = buf, desc = "move buffer down" })
    vim.keymap.set("n", "<A-k>", function() move_entry(-1) end, { buffer = buf, desc = "move buffer up" })
end

local function open_buflist()
    if state.floating_win_open then return end

    -- Open a scratch buffer that is wiped when closed.
    local buf = vim.api.nvim_create_buf(false, true)
    state.buf = buf
    vim.bo[buf].bufhidden = "wipe"

    local entries = render_bufs()

    local width = vim.api.nvim_get_option_value("columns", {})
    local height = vim.api.nvim_get_option_value("lines", {})
    local win_width = math.ceil(width * 0.8)
    local win_height = math.ceil(height * 0.8 - 4)
    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)
    local opts = {
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        border = "rounded"
    }
    local cur_buf = vim.api.nvim_get_current_buf()
    state.prev_win = vim.api.nvim_get_current_win()
    state.floating_win = vim.api.nvim_open_win(buf, true, opts)
    state.floating_win_open = true

    -- Set the cursor to focus on the current buf.
    local cursor_row = 1
    for i, entry in ipairs(entries) do
        if entry.id == cur_buf then
            cursor_row = i
            break
        end
    end
    vim.api.nvim_win_set_cursor(state.floating_win, { cursor_row, 0 })

    vim.api.nvim_create_autocmd({ "BufLeave" }, {
        buffer = buf,
        callback = function()
            vim.api.nvim_win_close(state.floating_win, true)
            state.floating_win_open = false
            return true
        end
    })

    set_local_keymaps()
end

vim.api.nvim_create_user_command("BuflistOpenWin", function()
    open_buflist()
end, {})

vim.keymap.set("n", "<leader>lb", ":BuflistOpenWin<CR>", { desc = "open buffer list" })

return M
