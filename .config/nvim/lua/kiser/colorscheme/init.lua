local prefix = "kiser/colorscheme/"

require(prefix .. "sonokai")    -- Prob the best
-- require(prefix .. "tokyonight") -- Ehh not good, should delete
-- require(prefix .. "gruvbox")    -- idk, kinda trash tbh
-- require(prefix .. "catppuccin") -- All of this just hurts my eyes,
--                                    but might be good if I get transparent backgrounds working
-- require(prefix .. "onedark")    -- Good dark blue type scheme

local ok, _ = pcall(vim.cmd, "colorscheme " .. Colorscheme)

if not ok then
    vim.notify("colorscheme " .. Colorscheme .. " not found.")
end
