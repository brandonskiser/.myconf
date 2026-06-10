local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality

local pick = require('kiser.obsidian.pick')

local T = MiniTest.new_set()

T['tag_items'] = MiniTest.new_set()

T['tag_items']['returns {tag, count, text} sorted alphabetically by tag'] = function()
    local idx = {
        by_tag = {
            zettel = { '/a.md', '/b.md', '/c.md' },
            fruit  = { '/x.md', '/y.md' },
            apple  = { '/z.md' },
        },
    }

    local got = pick.tag_items(idx)

    eq(got, {
        { tag = 'apple',  count = 1, text = 'apple (1)' },
        { tag = 'fruit',  count = 2, text = 'fruit (2)' },
        { tag = 'zettel', count = 3, text = 'zettel (3)' },
    })
end

T['tag_paths'] = MiniTest.new_set()

T['tag_paths']['returns the paths for a given tag, empty list if missing'] = function()
    local idx = { by_tag = { zettel = { '/a.md', '/b.md' } } }

    eq(pick.tag_paths(idx, 'zettel'), { '/a.md', '/b.md' })
    eq(pick.tag_paths(idx, 'missing'), {})
end

T['search_paths'] = MiniTest.new_set()

T['search_paths']['returns every indexed path'] = function()
    local idx = { paths = { '/a.md', '/b.md', '/c.md' } }

    eq(pick.search_paths(idx), { '/a.md', '/b.md', '/c.md' })
end

return T
