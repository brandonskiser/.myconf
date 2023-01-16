local util = require("kiser/lsp/util")

-- local config = util.default_opts
-- require 'lspconfig'.jdtls.setup(config)

local defaults = util.make_opts {}

local jdtls_install_location = vim.fn.expand('~/.local/share/nvim/mason/packages/jdtls/')
local jdtls_launcher_jar = vim.fn.glob(jdtls_install_location .. 'plugins/org.eclipse.equinox.launcher_*')

-- Sets the project name to the name of the directory neovim was launched from.
-- i.e., if you started neovim within `~/dev/xy/project-1` this would resolve to `project-1`
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local path_to_project = vim.fn.fnamemodify(vim.fn.getcwd(), ':h')
local workspace_dir = path_to_project .. '/' .. project_name

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local jdtls_config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {

        -- 💀
        'java', -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xms1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens', 'java.base/java.util=ALL-UNNAMED',
        '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

        -- 💀
        '-jar', jdtls_launcher_jar,

        -- 💀
        '-configuration', jdtls_install_location .. 'config_linux',

        -- 💀
        -- See `data directory configuration` section in the README
        '-data', workspace_dir
    },

    -- 💀
    -- This is the default if not provided, you can remove it. Or adjust as needed.
    -- One dedicated LSP server & client will be started per unique root_dir
    root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),

    -- Here you can configure eclipse.jdt.ls specific settings
    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    -- for a list of options
    settings = {
        java = {
        }
    },

    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    init_options = {
        bundles = {}
    },

    on_attach = defaults.on_attach,
    capabilities = defaults.capabilities,
    flags = defaults.flags,
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        require('jdtls').start_or_attach(jdtls_config)
    end
})

