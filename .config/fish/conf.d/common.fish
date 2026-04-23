# Shared config — sourced via conf.d, tracked in dotfiles.
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
