local prefix = "kiser/colorscheme/"

-- require(prefix .. "sonokai")
-- require(prefix .. "tokyonight")
-- require(prefix .. "gruvbox")
-- require(prefix .. "catppuccin")
require(prefix .. "onedark")

local ok, _ = pcall(vim.cmd, "colorscheme " .. Colorscheme)

if not ok then
    vim.notify("colorscheme " .. Colorscheme .. " not found.")
end
