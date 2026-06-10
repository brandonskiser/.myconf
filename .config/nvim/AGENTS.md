# AGENTS.md

Quick context for agents working in this nvim config.

## Dotfiles: bare checkout

This directory is tracked by a bare git repo at `~/.myconf` (origin: https://github.com/brandonskiser/.myconf), with `$HOME` as the work tree. Files here are NOT in a normal repo - regular `git` commands run from `~/.config/nvim/` will reference an unrelated repo (or none).

Use `cnf` instead of `git` for any dotfile state operations:

- `cnf` is `~/.bin/cnf`, a wrapper for `git --git-dir="$HOME/.myconf/" --work-tree="$HOME" "$@"`
- Examples: `cnf status`, `cnf diff`, `cnf log -- ~/.config/nvim/init.lua`, `cnf add <path>`, `cnf commit -m "..."`

## Tracking new files: `cnf-add-all`

`~/.bin/cnf-add-all` is the curated list of paths to stage. Both `~/.config/nvim/` and `~/.config/nvim_0_12/` are already included.

- To stage all tracked dotfile paths: run `cnf-add-all`
- To track a NEW path not yet listed: edit `~/.bin/cnf-add-all` to append a `cnf add "$HOME/<path>"` line, then run it
- After staging, commit with `cnf commit -m "..."` and push with `cnf push`

## Notes

- `~/.gitignore` (tracked by `cnf`) controls what the bare repo ignores under `$HOME`
- Sibling config `~/.config/nvim_0_12/` exists for the Neovim 0.12 variant; treat as a separate config root
