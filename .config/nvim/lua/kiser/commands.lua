-- Not really sure what this does but you can do something like:
-- ':Dump digraphs' which outputs :digraphs into the current buffer.
-- or, ':Dump messages' to view e.g. the vim.notify output logs.
vim.api.nvim_create_user_command('Dump', function(input)
  vim.cmd("put =execute('" .. input.args .. "')")
end, { nargs = 1 })

vim.api.nvim_create_user_command('QuickFixListClear', 'cexpr []', {})

