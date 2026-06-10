local MiniTest = require('mini.test')
local eq = MiniTest.expect.equality

local note = require('kiser.obsidian.note')

local T = MiniTest.new_set()

--- Make a fresh tmpdir for an individual test case.
--- @return string
local function fresh_tmpdir()
    local dir = vim.fn.tempname()
    vim.fn.mkdir(dir, 'p')
    return dir
end

--- Read a whole file as a single string.
--- @param path string
--- @return string
local function read(path)
    return table.concat(vim.fn.readfile(path), '\n')
end

T['new'] = MiniTest.new_set()

T['new']['writes a file at <dir>/<id>.md with the requested frontmatter'] = function()
    local dir = fresh_tmpdir()

    local path = note.new({
        id = '20240101T000000Z_hello',
        title = 'Hello',
        aliases = { 'Hello' },
        tags = { 'zettel' },
        dir = dir,
    })

    eq(path, dir .. '/20240101T000000Z_hello.md')
    eq(vim.uv.fs_stat(path) ~= nil, true)

    local content = read(path)
    eq(content:match('id: 20240101T000000Z_hello') ~= nil, true)
    eq(content:match('  %- Hello') ~= nil, true)
    eq(content:match('  %- zettel') ~= nil, true)
end

T['new']['refuses to overwrite an existing file'] = function()
    local dir = fresh_tmpdir()
    local spec = {
        id = 'dup',
        title = 'Dup',
        aliases = { 'Dup' },
        tags = {},
        dir = dir,
    }

    local path = note.new(spec)
    -- Mutate the file so we can prove it was not rewritten.
    vim.fn.writefile({ 'sentinel' }, path)

    local ok, err = pcall(note.new, spec)

    eq(ok, false)
    eq(type(err) == 'string' and err:match('refusing to overwrite') ~= nil, true)
    eq(read(path), 'sentinel')
end

T['new']['produces frontmatter that round-trips through parse_file'] = function()
    local frontmatter = require('kiser.obsidian.frontmatter')
    local dir = fresh_tmpdir()

    local path = note.new({
        id = 'rt-id',
        title = 'Round Trip',
        aliases = { 'Round Trip', 'RT' },
        tags = { 'zettel', 'meta' },
        dir = dir,
    })

    eq(frontmatter.parse_file(path), {
        id = 'rt-id',
        aliases = { 'Round Trip', 'RT' },
        tags = { 'zettel', 'meta' },
    })
end

T['gen_id'] = MiniTest.new_set()

T['gen_id']['formats as <utc-iso-no-colons>Z_<slug>'] = function()
    local id = note.gen_id('Hello World')

    -- 2024-01-01T000000Z_hello-world (only colons stripped, dashes preserved)
    eq(id:match('^%d%d%d%d%-%d%d%-%d%dT%d%d%d%d%d%dZ_hello%-world$') ~= nil, true)
end

T['gen_id']['uses four random uppercase letters when title is nil'] = function()
    local id = note.gen_id(nil)

    eq(id:match('^%d%d%d%d%-%d%d%-%d%dT%d%d%d%d%d%dZ_[A-Z][A-Z][A-Z][A-Z]$') ~= nil, true)
end

T['gen_id']['drops disallowed characters from the slug'] = function()
    local id = note.gen_id("Foo, Bar! What's up?")

    -- Disallowed chars are stripped; spaces become hyphens.
    eq(id:match('_foo%-bar%-whats%-up$') ~= nil, true)
end

T['gen_id']['rapid successive nil-title calls produce distinct ids'] = function()
    -- Random 4-char uppercase suffix has 26^4 = 456,976 combos; collisions
    -- in 50 calls within one second are statistically negligible. Anything
    -- worse than 49/50 distinct indicates the PRNG is stuck (unseeded or
    -- broken).
    local ids = {}
    for _ = 1, 50 do ids[note.gen_id(nil)] = true end
    eq(vim.tbl_count(ids) >= 49, true)
end

return T
