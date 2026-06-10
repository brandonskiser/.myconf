local function req(module)
    local ok, _ = pcall(require, module)
    if not ok then
        print("Module `" .. module .. "` unable to be imported.")
    end
end

req("kiser.util")

req("kiser.defaults")
req("kiser.keymaps")
req("kiser.commands")
req("kiser.filetypes")
req("kiser.buflist")
req("kiser.diagnostics")

-- require("kiser.treesit_navigator").setup()
-- vim.api.nvim_create_user_command('TSNavigator', function()
--     require("kiser.treesit_navigator").ts_tree_display()
-- end, { desc = 'Navigate the parsed treesitter tree' })

req("kiser.plugins")

-- Set colorscheme after all plugins are done installing
req("kiser.colorscheme")
