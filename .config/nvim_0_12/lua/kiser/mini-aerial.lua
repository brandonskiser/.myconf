-- mini.pick integration for aerial.nvim
-- Provides a fuzzy picker for buffer symbols (functions, classes, etc.)
local M = {}

function M.pick()
    require("aerial").sync_load()
    local backends = require("aerial.backends")
    local config = require("aerial.config")
    local data = require("aerial.data")
    local highlight = require("aerial.highlight")

    local bufnr = vim.api.nvim_get_current_buf()

    -- aerial supports different backends (treesitter, lsp, etc.)
    -- from which symbols are fetched
    -- Get the backend for the current buffer
    local backend = backends.get()
    if not backend then
        backends.log_support_err()
        return
    end

    -- Fetch symbols if not already cached
    if not data.has_symbols(bufnr) then
        backend.fetch_symbols_sync(bufnr, {})
    end


    -- Build picker items from aerial symbols
    ---@class AerialPickItem
    ---@field text string Display text with indent, icon, and name
    ---@field lnum integer Line number to jump to
    ---@field col integer Column number to jump to
    ---@field hl string? Highlight group for the item
    ---@type AerialPickItem[]
    local items = {}
    local bufdata = data.get_or_create(bufnr)
    local buf_lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

    -- First pass: collect data and find max name width (including indent)
    local raw_items = {}
    local max_name_width = 0
    local max_lnum = 0
    for _, item in bufdata:iter({ skip_hidden = false }) do
        local icon = config.get_icon(bufnr, item.kind)
        local indent = string.rep("  ", item.level)
        local lnum = item.selection_range and item.selection_range.lnum or item.lnum
        local name_part = indent .. icon .. " " .. item.name
        max_name_width = math.max(max_name_width, vim.fn.strdisplaywidth(name_part))
        max_lnum = math.max(max_lnum, lnum)
        table.insert(raw_items, {
            name_part = name_part,
            lnum = lnum,
            col = item.selection_range and item.selection_range.col or item.col,
            hl = highlight.get_highlight(item, false, false),
            line_content = vim.trim(buf_lines[lnum] or ""),
        })
    end

    -- Second pass: build items with aligned columns
    local lnum_width = #tostring(max_lnum)
    for _, raw in ipairs(raw_items) do
        local padding = string.rep(" ", max_name_width - vim.fn.strdisplaywidth(raw.name_part))
        table.insert(items, {
            text = string.format("%s%s | %" .. lnum_width .. "d: %s", raw.name_part, padding, raw.lnum, raw.line_content),
            lnum = raw.lnum,
            col = raw.col,
            hl = raw.hl,
        })
    end

    require("mini.pick").start({
        source = {
            name = "Aerial Symbols",
            items = items,

            -- Custom show: render lines with syntax highlighting
            show = function(buf_id, items_to_show, _query)
                --- @type string[]
                local lines = vim.tbl_map(function(item) return item.text end, items_to_show)
                vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
                for i, item in ipairs(items_to_show) do
                    if item.hl then
                        vim.api.nvim_buf_add_highlight(buf_id, -1, item.hl, i - 1, 0, -1)
                    end
                end
            end,

            -- Custom match: case-insensitive substring matching
            match = function(stritems, indices, query)
                local prompt = table.concat(query)
                if prompt == "" then return indices end
                local matched = {}
                for _, idx in ipairs(indices) do
                    if stritems[idx]:lower():find(prompt:lower(), 1, true) then
                        table.insert(matched, idx)
                    end
                end
                return matched
            end,

            -- Preview: show buffer content around the symbol
            preview = function(buf_id, item)
                local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
                vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
                vim.bo[buf_id].filetype = vim.bo[bufnr].filetype
                local win = vim.fn.bufwinid(buf_id)
                if win ~= -1 then
                    vim.wo[win].number = true
                    vim.wo[win].cursorline = true
                    vim.api.nvim_win_set_cursor(win, { item.lnum, item.col })
                    vim.api.nvim_win_call(win, function() vim.cmd("normal! zz") end)
                end
            end,

            -- Custom choose: jump to symbol location in original window
            choose = function(item)
                if item then
                    local target = require("mini.pick").get_picker_state().windows.target
                    vim.api.nvim_win_set_cursor(target, { item.lnum, item.col })
                end
                -- return nil to close picker
            end,
        },
    })
end

return M
