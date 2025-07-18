local M = {}

local defaults = require('kiser.plugins.lsp.util').make_opts { }

local IS_WORK_LAPTOP = require('kiser.util.env').is_work_laptop()
local HOME = os.getenv("HOME")

-- local root_dir = IS_WORK_LAPTOP and require('kiser.util.path').find_root({ 'packageInfo' }, 'Config')
--     or require('kiser.util.path').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml' })
-- haven't tested this out yet so keeping this above code commented
local root_dir = IS_WORK_LAPTOP and vim.fs.root(vim.fs.joinpath(vim.env.PWD, 'Config'), { 'packageInfo' })
    or vim.fs.root(0, { '.git', 'mvnw', 'gradlew', 'pom.xml' })

local jdtls_install_location = HOME .. '/.local/share/nvim/mason/packages/jdtls/'
local jdtls_bin_path = jdtls_install_location .. 'bin/jdtls'
local lombok_jar_path = jdtls_install_location .. 'lombok.jar'

-- Set where jdtls stores project specific data. I have two options here, within ~/.local or just in the project's root itself.
local jdtls_data_dir = root_dir -- OR: HOME .. '/.local/share/jdtls/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')

local ws_folders_jdtls = {}
if IS_WORK_LAPTOP and root_dir then
    local file = io.open(root_dir .. "/.bemol/ws_root_folders")
    if file then
        for line in file:lines() do
            table.insert(ws_folders_jdtls, "file://" .. line)
        end
        file:close()
    end
end

-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
M.jdtls_config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {
        jdtls_bin_path,
        "--jvm-arg=-javaagent:" .. lombok_jar_path, -- Needed for Lombok magic.

        -- See `data directory configuration` section in the README
        '-data', jdtls_data_dir
    },
    -- One dedicated LSP server & client will be started per unique root_dir
    root_dir = root_dir,
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
        -- workspaceFolders = ws_folders_jdtls,
        bundles = {}
    },
    capabilities = defaults.capabilities,
    flags = defaults.flags,
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "java",
    callback = function()
        require('jdtls').start_or_attach(M.jdtls_config)
    end
})

return M
