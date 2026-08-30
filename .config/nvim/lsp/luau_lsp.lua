local function project_settings(root_dir)
    if not root_dir then
        return nil
    end

    -- Prefer using LSP settings configured per `.vscode/settings.json` if it exists.
    local path = vim.fs.joinpath(root_dir, ".vscode", "settings.json")
    local file = io.open(path, "r")
    if not file then
        return nil
    end

    local body = file:read("*a")
    file:close()
    local ok, decoded = pcall(vim.json.decode, body)
    if not ok or type(decoded) ~= "table" then
        return nil
    end

    local nested = {}
    for key, value in pairs(decoded) do
        if key:find("^luau%-lsp%.") then
            local node = nested
            local parts = vim.split(key, ".", { plain = true })
            for i = 1, #parts - 1 do
                node[parts[i]] = node[parts[i]] or {}
                node = node[parts[i]]
            end
            node[parts[#parts]] = value
        end
    end

    return next(nested) and nested or nil
end

local function merge_in_place(target, source)
    local merged = vim.tbl_deep_extend("force", target, source)
    for key, value in pairs(merged) do
        target[key] = value
    end
end

--- @type vim.lsp.Config
return {
    filetypes = { "luau" },
    root_markers = { ".luaurc", ".git" },
    settings = {
        ["luau-lsp"] = {
            platform = { type = "standard" },
        },
    },
    cmd = function(dispatchers, config)
        local command = { "luau-lsp", "lsp" }
        local project = project_settings(config.root_dir)
        ---@type string[]
        local definitions = project
                and vim.tbl_get(project, "luau-lsp", "types", "definitionFiles")

        for _, definition in ipairs(definitions) do
            if not vim.startswith(definition, "/") then
                definition = vim.fs.joinpath(config.root_dir or vim.uv.cwd(), definition)
            end
            if vim.uv.fs_stat(definition) then
                table.insert(command, "--definitions=" .. definition)
            end
        end

        return vim.lsp.rpc.start(command, dispatchers, { cwd = config.root_dir })
    end,
    before_init = function(_, config)
        local project = project_settings(config.root_dir)
        if project then
            merge_in_place(config.settings, project)
        end
    end,
}
