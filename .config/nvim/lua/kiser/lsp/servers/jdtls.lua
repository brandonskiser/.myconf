local util = require("kiser/lsp/util")

local defaults = util.make_opts {
    on_attach = function()
        require('jdtls.setup').add_commands()
        -- nnoremap <A-o> <Cmd>lua require'jdtls'.organize_imports()<CR>
        -- nnoremap crv <Cmd>lua require('jdtls').extract_variable()<CR>
        -- vnoremap crv <Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>
        -- nnoremap crc <Cmd>lua require('jdtls').extract_constant()<CR>
        -- vnoremap crc <Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>
        -- vnoremap crm <Esc><Cmd>lua require('jdtls').extract_method(true)<CR>
        -- vim.api.nvim_create_user_command
        -- vim.fn.nvim_create_user_command

        -- vim.api.nvim_create_user_command
    end
}

local IS_WORK_LAPTOP = os.getenv('LOGNAME') == 'bskiser'
local HOME = os.getenv("HOME")

local root_dir = IS_WORK_LAPTOP and require('jdtls.setup').find_root({ 'packageInfo' }, 'Config')
    or require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml' })

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
local jdtls_config = {
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
