-- tokyonight - available colorschemes
local colorscheme = "tokyonight"
-- local colorscheme = "tokyonight-night"
-- local colorscheme = tokyonight-storm
-- local colorscheme = tokyonight-day
-- local colorscheme = tokyonight-moon
-- local colorscheme = "tokyonight-moon"


-- vim.cmd("let g:sonokai_style = 'atlantis'")
-- vim.cmd("let g:sonokai_style = 'andromeda'")
-- vim.cmd("let g:sonokai_style = 'shusia'")
-- vim.cmd("let g:sonokai_style = 'maia'")
-- vim.cmd("let g:sonokai_style = 'espresso'")
-- local colorscheme = "sonokai"

-- gruvbox
-- require("gruvbox").setup({
--     contrast = "soft"
-- })
-- vim.cmd("set background=dark")
-- local colorscheme = "gruvbox"

local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not ok then
    vim.notify("colorscheme " .. colorscheme .. " not found.")
end
