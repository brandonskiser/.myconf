local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality

local link = require('kiser.obsidian.link')

local T = MiniTest.new_set()

T['find_all'] = MiniTest.new_set()

T['find_all']['returns a single bare link'] = function()
    local got = link.find_all('see [[foo]] for details')

    eq(got, { { target = 'foo' } })
end

T['find_all']['splits target and alias on the pipe'] = function()
    local got = link.find_all('see [[foo|Foo Display]] for details')

    eq(got, { { target = 'foo', alias = 'Foo Display' } })
end

T['find_all']['returns multiple links in order'] = function()
    local got = link.find_all('first [[a]] then [[b|B]] and [[c]]')

    eq(got, {
        { target = 'a' },
        { target = 'b', alias = 'B' },
        { target = 'c' },
    })
end

T['find_all']['ignores embed syntax (![[target]])'] = function()
    local got = link.find_all('image: ![[picture]] and a real [[note]]')

    eq(got, { { target = 'note' } })
end

T['find_at'] = MiniTest.new_set()

T['find_at']['returns the link the cursor sits inside'] = function()
    -- Cursor positions are 1-indexed columns, matching nvim_win_get_cursor + 1.
    -- Line: "see [[foo]] for details"
    --       12345678901234
    -- The body of [[foo]] sits at columns 5-11.
    local got = link.find_at('see [[foo]] for details', 7)

    eq(got, { target = 'foo' })
end

T['find_at']['returns nil when the cursor is between links'] = function()
    -- Line: "[[a]] gap [[b]]"
    --        12345678901234567
    -- Cursor at col 7 lands on the space between the two links.
    local got = link.find_at('[[a]] gap [[b]]', 7)

    eq(got, nil)
end

T['find_at']['matches when the cursor is on the opening or closing brackets'] = function()
    -- Line: "[[foo]]"
    --        1234567
    -- col 1 is the opening `[`; col 7 is the closing `]`.
    eq(link.find_at('[[foo]]', 1), { target = 'foo' })
    eq(link.find_at('[[foo]]', 7), { target = 'foo' })
end

T['find_at']['picks the link the cursor is on, not a neighbor'] = function()
    -- Line: "[[a]] [[b]]"
    --        12345678901
    -- cols 1-5 -> a; cols 7-11 -> b.
    eq(link.find_at('[[a]] [[b]]', 3), { target = 'a' })
    eq(link.find_at('[[a]] [[b]]', 9), { target = 'b' })
end

T['find_at']['returns nil when the cursor is on an embed'] = function()
    eq(link.find_at('![[picture]]', 5), nil)
end

return T
