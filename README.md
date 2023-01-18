# Install
```
git clone --bare https://github.com/brandonskiser/.myconf.git "$HOME"/.myconf
alias cnf='/usr/bin/env git --git-dir="$HOME"/.myconf --work-tree="$HOME"'
cnf checkout
```
To use the shell rc, source `.commonrc`.
```
echo "source ~/.commonrc" >> .bashrc
```


If you get an error like the following:
```
error: The following untracked working tree files would be overwritten by checkout:
        .tmux.conf
Please move or remove them before you switch branches.
Aborting
```
Simply backup or remove the files.

### Prerequisites
Install a patched font. I use Hack Nerd Font. Checkout their releases for a link: https://github.com/ryanoasis/nerd-fonts/releases
Your terminal needs to be using the Hack Mono font.

### Git config overrides
To override git config (e.g., for setting work email), create a config `.gitconfig-work` with your overrides, e.g.
```
[user]
    email = "workemail"
```
