local ok, _ = pcall(require, 'monokai-pro')
if not ok then
    print('monokai-pro not installed')
end

require('monokai-pro').setup()

Colorscheme = 'monokai-pro'
