local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality

local frontmatter = require('kiser.obsidian.frontmatter')

local T = MiniTest.new_set()

T['parse'] = MiniTest.new_set()

T['parse']['extracts id, aliases, and tags from a complete block'] = function()
    local text = table.concat({
        '---',
        'id: 20240101T000000Z_hello',
        'aliases:',
        '  - Hello',
        '  - Greeting',
        'tags:',
        '  - zettel',
        '  - intro',
        '---',
        '',
        '# Hello',
        '',
        'body text',
    }, '\n')

    local got = frontmatter.parse(text)

    eq(got, {
        id = '20240101T000000Z_hello',
        aliases = { 'Hello', 'Greeting' },
        tags = { 'zettel', 'intro' },
    })
end

T['parse']['defaults missing fields to nil id and empty lists'] = function()
    local text = table.concat({
        '---',
        'id: only-id',
        '---',
        'body',
    }, '\n')

    local got = frontmatter.parse(text)

    eq(got, { id = 'only-id', aliases = {}, tags = {} })
end

T['parse']['returns defaults when there is no frontmatter block'] = function()
    local text = '# Just a Heading\n\nNo frontmatter here.\n'

    local got = frontmatter.parse(text)

    eq(got, { id = nil, aliases = {}, tags = {} })
end

T['parse']['handles flow-style list syntax for aliases and tags'] = function()
    local text = table.concat({
        '---',
        'id: flow',
        'aliases: [Foo, Bar]',
        'tags: [zettel, intro]',
        '---',
    }, '\n')

    local got = frontmatter.parse(text)

    eq(got, {
        id = 'flow',
        aliases = { 'Foo', 'Bar' },
        tags = { 'zettel', 'intro' },
    })
end

T['parse']['strips surrounding quotes from scalars and list items'] = function()
    local text = table.concat({
        '---',
        'id: "20240101T000000Z_quoted"',
        "aliases: ['Quoted Alias', \"Another\"]",
        'tags:',
        '  - "quoted-tag"',
        "  - 'single-tag'",
        '---',
    }, '\n')

    local got = frontmatter.parse(text)

    eq(got, {
        id = '20240101T000000Z_quoted',
        aliases = { 'Quoted Alias', 'Another' },
        tags = { 'quoted-tag', 'single-tag' },
    })
end

T['parse']['falls back to defaults on unterminated fence'] = function()
    local text = table.concat({
        '---',
        'id: never-closed',
        'aliases:',
        '  - Foo',
        '',
        'body without closing fence',
    }, '\n')

    local got = frontmatter.parse(text)

    eq(got, { id = nil, aliases = {}, tags = {} })
end

T['parse_file'] = MiniTest.new_set()

T['parse_file']['reads and parses an existing file'] = function()
    local tmpdir = vim.fn.tempname()
    vim.fn.mkdir(tmpdir, 'p')
    local path = tmpdir .. '/note.md'
    local text = table.concat({
        '---',
        'id: from-file',
        'aliases:',
        '  - From File',
        'tags:',
        '  - zettel',
        '---',
        '',
        'body',
    }, '\n')
    vim.fn.writefile(vim.split(text, '\n', { plain = true }), path)

    local got = frontmatter.parse_file(path)

    eq(got, {
        id = 'from-file',
        aliases = { 'From File' },
        tags = { 'zettel' },
    })
end

T['parse_file']['returns defaults when the file is missing'] = function()
    local got = frontmatter.parse_file('/nonexistent/path/that/should/not/exist.md')

    eq(got, { id = nil, aliases = {}, tags = {} })
end

return T
