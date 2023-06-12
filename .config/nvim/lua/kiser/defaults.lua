-- :help options
local options = {
    mouse = "a",              -- allows mouse to be used in all modes
    relativenumber = true,    -- relative line numbers from current cursor, for easy jumping 
    number = true,            -- use absolute line number for current cursor
    shiftwidth = 4,           -- number of spaces inserted for each indentation
    tabstop = 4,              -- number of spaces displayed for a tab character
    expandtab = true,         -- whether or not tab should be expanded into spaces
    cursorline = true,       -- highlight the current line
    ignorecase = true,        -- ignore case in searches
    smartcase = true,         -- ignore case in searches, unless the search includes uppercase characters
    termguicolors = true,

    -- display invisible characters
    -- eol   - U+23CE RETURN SYMBOL
    -- trail - U+2420 SYMBOL FOR SPACE
    -- nbsp  - U+23B5 BOTTOM SQUARE BRACKET
    list = true,
    listchars = "eol:⏎,tab:␉·,trail:␠,nbsp:⎵",

    showtabline = 2,          -- yeah
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

-- Use system clipboard for yank and paste. Commented out because
-- I like having a separate vim yank register.
-- https://stackoverflow.com/questions/30691466/what-is-difference-between-vims-clipboard-unnamed-and-unnamedplus-settings
-- vim.cmd "set clipboard+=unnamed,unnamedplus"
-- vim.opt.clipboard:append { "unnamed", "unnamedplus" }
