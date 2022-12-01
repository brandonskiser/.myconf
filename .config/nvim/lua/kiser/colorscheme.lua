-- tokyonight - available colorschemes
-- colorscheme tokyonight
-- colorscheme tokyonight-night
-- colorscheme tokyonight-storm
-- colorscheme tokyonight-day
-- colorscheme tokyonight-moon
-- local colorscheme = "tokyonight-moon"


vim.cmd("let g:sonokai_style = 'atlantis'")
-- vim.cmd("let g:sonokai_style = 'andromeda'")
-- vim.cmd("let g:sonokai_style = 'shusia'")
-- vim.cmd("let g:sonokai_style = 'maia'")
-- vim.cmd("let g:sonokai_style = 'espresso'")
local colorscheme = "sonokai"


local ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)

if not ok then
    vim.notify("colorscheme " .. colorscheme .. " not found.")
end
