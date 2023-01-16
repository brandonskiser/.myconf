local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap

-- Modes
--   normal_mode = "n"
--   insert_mode = "i"
--   visual_mode = "v"
--   visual_block_mode = "x"
--   term_mode = "t"
--   command_mode = "c"

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<C-s>", ":w<CR>", opts)
keymap("i", "<C-s>", "<C-o>:w<CR>", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Center screen after going up/down a half page
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)

-- Resize with arrows
keymap("n", "<C-Up>",    ":resize +2<CR>", opts)
keymap("n", "<C-Down>",  ":resize -2<CR>", opts)
keymap("n", "<C-Left>",  ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Move text up and down
-- https://vim.fandom.com/wiki/Moving_lines_up_or_down#:~:text=In%20normal%20mode%20or%20in,to%20move%20the%20block%20up.
-- For normal mode, == re-indents the line to suit its new position. For visual mode, gv reselects the last visual block
-- and = re-indents that block.
keymap("n", "<A-j>", ":m .+1<CR>==", opts) -- can be abbreviated to :m+
keymap("n", "<A-k>", ":m .-2<CR>==", opts) -- can be abbreviated to :m-2
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- See default windows mappings: https://neovim.io/doc/user/windows.html
-- By default, window commands (:wincmd) are prefixed with <C-w>. Here, I'm just remapping commonly
-- used ones to <leader> instead, so <C-w> can be used later.
keymap("n", "<leader>w\\", ":vsplit<CR>", opts)       -- vertical split
keymap("n", "<leader>w-", ":split<CR>", opts)         -- horizontal split
keymap("n", "<leader>wq", ":q<CR>", opts)             -- quit current window, will exit nvim if it's the last window
keymap("n", "<leader>wc", ":clo<CR>", opts)           -- close current window (won't exit nvim if it's last window)
keymap("n", "<leader>wr", ":wincmd r<CR>", opts)      -- rotate window to the right/down
keymap("n", "<leader>we", ":wincmd R<CR>", opts)      -- rotate window to the left/up
keymap("n", "<leader>wo", ":wincmd o<CR>", opts)      -- make current window the only window
keymap("n", "<leader>wT", ":wincmd T<CR>", opts)      -- move current window to a new tab page

-- Copying to the system clipboard.
keymap("n", "<leader>y", '"+y', opts)
keymap("v", "<leader>y", '"+y', opts)
keymap("x", "<leader>y", '"+y', opts)
keymap("n", "<leader>p", '"+p', opts)
keymap("n", "<leader>yB", ":let @+ = expand('%:p')", opts) -- yank the absolute path of the current buffer to the clipboard

-- Disable search highlight
keymap("n", "<leader>n", ":noh<CR>", opts)

-- Open a URL in the default web browser. Note that CTRL_R+CTRL_A is a keybind in command line mode
-- to copy over the WORD under the cursor into the cmdline. See :h c_CTRL-R_CTRL-A for others
keymap("n", "gx", ":!xdg-open <C-r><C-a><CR>", opts)

