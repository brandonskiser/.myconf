-- mini.pick integration for aerial.nvim
-- Provides a fuzzy picker for buffer symbols (functions, classes, etc.)
local M = {}

---@class BufHighlight
---@field start_col integer
---@field end_col integer
---@field hl_group string

-- Collect treesitter highlights for each line in the buffer.
-- Returns a table mapping 0-indexed row numbers to arrays of highlights.
---@param bufnr integer
---@return table<integer, BufHighlight[]>
local function collect_buf_highlights(bufnr)
    -- Get the treesitter parser for this buffer
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
    if not ok or not parser then return {} end

    ---@type table<integer, BufHighlight[]>
    local highlights = {}

    -- Get the "highlights" query for this language (defines syntax highlighting rules)
    local query = vim.treesitter.query.get(parser:lang(), "highlights")
    if query then
        -- Iterate over all matches in the syntax tree for the given buffer
        for _, captures in query:iter_matches(parser:trees()[1]:root(), bufnr, 0, -1, { all = false }) do
            for id, node in pairs(captures) do
                -- Get the position of this syntax node
                local start_row, start_col, _, end_col = node:range()
                highlights[start_row] = highlights[start_row] or {}
                -- Strip subtypes from capture name (e.g. "keyword.return" -> "keyword")
                local hl_name = query.captures[id]:match("^[^.]+")
                table.insert(highlights[start_row], {
                    start_col = start_col,
                    end_col = end_col,
                    hl_group = "@" .. hl_name, -- prefix with @ for treesitter highlight groups
                })
            end
        end
    end
    return highlights
end

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

    -- Collect treesitter highlights for code preview
    local buf_highlights = collect_buf_highlights(bufnr)

    -- Build picker items from aerial symbols
    ---@class AerialPickItem
    ---@field text string Display text with indent, icon, and name
    ---@field lnum integer Line number to jump to
    ---@field col integer Column number to jump to
    ---@field hl string? Highlight group for the item
    ---@field code_hl table? Treesitter highlights for code portion
    ---@field code_offset integer Offset where code content starts
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
        local line = buf_lines[lnum] or ""
        local trimmed = vim.trim(line)
        local leading_ws = #(line:match("^%s*") or "")
        table.insert(raw_items, {
            name_part = name_part,
            lnum = lnum,
            col = item.selection_range and item.selection_range.col or item.col,
            hl = highlight.get_highlight(item, false, false),
            line_content = trimmed,
            leading_ws = leading_ws,
        })
    end

    -- Second pass: build items with aligned columns
    local lnum_width = #tostring(max_lnum)
    for _, raw in ipairs(raw_items) do
        local padding = string.rep(" ", max_name_width - vim.fn.strdisplaywidth(raw.name_part))
        local prefix = string.format("%s%s | %" .. lnum_width .. "d: ", raw.name_part, padding, raw.lnum)
        table.insert(items, {
            text = prefix .. raw.line_content,
            lnum = raw.lnum,
            col = raw.col,
            hl = raw.hl,
            code_hl = buf_highlights[raw.lnum - 1],
            code_offset = #prefix - raw.leading_ws,
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
                local ns = vim.api.nvim_create_namespace("mini_aerial")
                vim.api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
                for i, item in ipairs(items_to_show) do
                    -- Apply symbol highlight to name portion
                    if item.hl then
                        vim.api.nvim_buf_set_extmark(buf_id, ns, i - 1, 0, {
                            end_col = #item.text,
                            hl_group = item.hl,
                        })
                    end
                    -- Apply treesitter highlights to code portion
                    if item.code_hl then
                        for _, hl in ipairs(item.code_hl) do
                            pcall(vim.api.nvim_buf_set_extmark, buf_id, ns, i - 1,
                                hl.start_col + item.code_offset, {
                                    end_col = hl.end_col + item.code_offset,
                                    hl_group = hl.hl_group,
                                })
                        end
                    end
                end
            end,

            -- Use mini.pick's default fuzzy matching
            match = function(stritems, indices, query)
                return MiniPick.default_match(stritems, indices, query)
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
