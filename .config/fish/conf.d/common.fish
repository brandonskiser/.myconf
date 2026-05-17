# Shared config sourced via conf.d, tracked in dotfiles.
# Uses bass to import POSIX shell env/aliases into fish.
bass source ~/.commonrc
bass source ~/.common_aliases

if status is-interactive
    alias bb='brazil-build'
end

# y - yazi wrapper that cds on exit
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# brew setup - adds brew to PATH
if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /home/linuxbrew/.linuxbrew/bin/brew
    eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
end

# Loaded after brew so it's on PATH if brew-installed
if command -q direnv
    direnv hook fish | source
end

# fish_add_path: fish builtin that prepends to $PATH, deduplicating automatically.

# bun setup
if test -d "$HOME/.bun/bin"
    set -gx BUN_INSTALL "$HOME/.bun"
    fish_add_path "$BUN_INSTALL/bin"
end

# toolbox setup (Amazon specific)
if test -d "$HOME/.toolbox/bin"
    fish_add_path "$HOME/.toolbox/bin"
end
