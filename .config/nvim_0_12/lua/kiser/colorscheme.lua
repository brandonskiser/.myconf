Colorscheme = "cyberdream"

if Colorscheme == nil then
    return
end

local ok, _ = pcall(vim.cmd, "colorscheme " .. Colorscheme)

if not ok then
    vim.notify("colorscheme " .. Colorscheme .. " not found.")
end

