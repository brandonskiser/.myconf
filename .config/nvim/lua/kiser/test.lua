local a = require("plenary.async")

local function read_first_dir_entry()
  os.execute("sleep 2")
  vim.notify("Opening .")
  local fs, err = vim.loop.fs_opendir(".")
  if not fs then return vim.notify("Could not opendir: " .. err, vim.log.levels.ERROR) end
  vim.notify("Opened .")

  local readdir_err, entries = a.uv.fs_readdir(fs)
  vim.notify("After async.uv.fs_readdir")
  if readdir_err then vim.notify("Could not readdir: " .. readdir_err, vim.log.levels.ERROR) end
  if not entries then return end
  print(vim.inspect(entries[1]))
end

vim.notify("Before a.run")
a.run(read_first_dir_entry, function() vim.notify("Done") end)
vim.notify("After a.run")
os.execute("sleep 2")

