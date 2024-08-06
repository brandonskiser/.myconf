local function req(module)
    local ok, _ = pcall(require, module)
    if not ok then
        print('Module `' .. module .. '` unable to be imported.')
    end
end

local function lazy_setup()
    req('kiser.defaults')
    req('kiser.keymaps')
    req('kiser.commands')
    req('kiser.filetypes')
    req('kiser.buflist')

    -- All plugin stuff
    require('kiser.lazy')

    req('kiser.colorscheme')
end

-- packer_setup()
lazy_setup()
