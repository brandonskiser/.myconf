if vim.fn.has("win32") == 1 then
    -- Adjust this path if your Git is installed in a different location
    local bash_path = [["C:\Program Files\Git\bin\bash.exe"]]
    vim.opt.shell = bash_path
    vim.opt.shellcmdflag = "-s"
    vim.opt.shellredir = ">%s 2>&1"
    vim.opt.shellquote = ""
    vim.opt.shellxescape = ""
    vim.opt.shellxquote = ""
    vim.opt.shellpipe = "2>&1| tee"
    vim.opt.shelltemp = false
end
