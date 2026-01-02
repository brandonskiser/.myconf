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
    for _, item in bufdata:iter({ skip_hidden = false }) do
        local icon = config.get_icon(bufnr, item.kind)
        local indent = string.rep("  ", item.level) -- indent to show hierarchy
        table.insert(items, {
            text = indent .. icon .. " " .. item.name,
            lnum = item.selection_range and item.selection_range.lnum or item.lnum,
            col = item.selection_range and item.selection_range.col or item.col,
            hl = highlight.get_highlight(item, false, false),
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
