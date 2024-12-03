# y shell wrapper that provides the ability to change the current working directory when exiting Yazi.
# use `y` instead of `yazi` to start
# use `q` to quit
# use `Q` to quit without changing cwd
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	yazi $argv --cwd-file="$tmp"
	if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
		builtin cd -- "$cwd"
	end
	rm -f -- "$tmp"
end
