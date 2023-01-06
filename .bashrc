#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias la='ls -a'
alias ll='la -l'
PS1='[\u@\h \W]\$ '

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/usr/local/vscode

. "$HOME/.cargo/env"

alias vim='nvim'

# alias for working with my dotfiles
alias config='git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
config config --local status.showUntrackedFiles no # Hide files we are not explicitly tracking yet
function config-add-all() {
    config add "$HOME/.config/nvim/"
    config add "$HOME/.bashrc"
    config add "$HOME/.tmux.conf"
    echo "Added"
}

export PATH=$PATH:/home/brandon/.local/share/nvim/site/pack/packer/start/fzf/bin
export PATH=$PATH:/home/brandon/.local/share/nvim/mason/bin

# if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} ]]
# then
# 	exec fish
# fi

alias lg='lazygit'

