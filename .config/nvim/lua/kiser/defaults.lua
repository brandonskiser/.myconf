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
    
    showtabline = 2,          -- yeah
}

for k, v in pairs(options) do
    vim.opt[k] = v
end
