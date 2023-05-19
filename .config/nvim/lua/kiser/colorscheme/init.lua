local prefix = "kiser/colorscheme/"

-- require(prefix .. "sonokai")    -- Prob the best
-- require(prefix .. "tokyonight") -- Ehh not good, should delete
-- require(prefix .. "gruvbox")    -- idk, kinda trash tbh
-- require(prefix .. "catppuccin") -- All of this just hurts my eyes,
--                                    but might be good if I get transparent backgrounds working
-- require(prefix .. "onedark")    -- Good dark blue type scheme
-- require(prefix .. "vscode")
require(prefix .. "monokai-pro")


if Colorscheme == nil then
    return
end

local ok, _ = pcall(vim.cmd, "colorscheme " .. Colorscheme)

if not ok then
    vim.notify("colorscheme " .. Colorscheme .. " not found.")
end
