local profile = require("kiser.plugins.profile")
local req = profile.req

--- Global helper to construct GitHub URLs for vim.pack.add
--- @param x string repository in "owner/repo" format
--- @return string
_G.gh = function(x) return "https://github.com/" .. x end

req("nvim-web-devicons")
req("lualine")
req("bufferline")
req("gitsigns")
req("mini-base16")
req("cyberdream")
req("oil")
req("nvim-surround")
req("mini-pick")
req("nvim-treesitter")
req("treesitter-context")
req("aerial")
req("rustaceanvim")
req("nvim-lspconfig")
req("cmp")
req("codecompanion")
req("lazydev")

vim.api.nvim_create_user_command("PluginProfile", profile.show, { desc = "Show plugin load times" })
