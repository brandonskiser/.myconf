local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality

local index = require('kiser.obsidian.index')

local T = MiniTest.new_set()

--- Materialize a fixture vault under a fresh tmpdir.
--- Each entry is `{ relpath, frontmatter_lines... }`.
--- @param files table<integer, string[]>
--- @return string root, table<integer, string> abs_paths (parallel to `files`)
local function make_vault(files)
    local root = vim.fn.tempname()
    vim.fn.mkdir(root, 'p')
    local paths = {}
    for i, entry in ipairs(files) do
        local rel = entry[1]
        local lines = { unpack(entry, 2) }
        local abs = root .. '/' .. rel
        vim.fn.mkdir(vim.fs.dirname(abs), 'p')
        vim.fn.writefile(lines, abs)
        paths[i] = abs
    end
    return root, paths
end

T['build'] = MiniTest.new_set()

T['build']['indexes a single note by id'] = function()
    local root, paths = make_vault({
        {
            'note.md',
            '---',
            'id: 20240101T000000Z_only',
            'aliases:',
            '  - Only',
            'tags:',
            '  - solo',
            '---',
            '',
            'body',
        },
    })

    local got = index.build({ root })

    eq(got.by_id['20240101T000000Z_only'], paths[1])
end

T['build']['populates by_alias (lowercase keys), by_tag, and paths'] = function()
    local root, paths = make_vault({
        {
            'a.md', '---', 'id: A', 'aliases:', '  - Apple', 'tags:',
            '  - fruit', '  - red', '---',
        },
        {
            'b.md', '---', 'id: B', 'aliases:', '  - Banana', 'tags:',
            '  - fruit', '---',
        },
    })

    local got = index.build({ root })

    eq(got.by_alias['apple'], paths[1])
    eq(got.by_alias['banana'], paths[2])
    -- Order of by_tag bucket follows traversal order; sort to compare.
    local fruit = vim.deepcopy(got.by_tag['fruit']); table.sort(fruit)
    local expected = { paths[1], paths[2] }; table.sort(expected)
    eq(fruit, expected)
    eq(got.by_tag['red'], { paths[1] })
    eq(#got.paths, 2)
end

T['build']['skips files under excluded directories'] = function()
    local root = make_vault({
        { '_templates/tpl.md', '---', 'id: TPL', '---' },
        { 'real.md', '---', 'id: REAL', '---' },
    })

    local got = index.build({ root }, { exclude_dirs = { '_templates' } })

    eq(got.by_id['TPL'], nil)
    eq(got.by_id['REAL'] ~= nil, true)
end

T['build']['picks up new files on each call (no caching)'] = function()
    local root, paths = make_vault({
        { 'a.md', '---', 'id: A', '---' },
    })

    local first = index.build({ root })
    eq(first.by_id['A'], paths[1])

    local new_path = root .. '/b.md'
    vim.fn.writefile({ '---', 'id: B', '---' }, new_path)

    local second = index.build({ root })
    eq(second.by_id['B'], new_path)
end

return T
