# dotfiles

Personal configuration for use on Fedora and WSL

## Requirements

- Git
- GNU Stow
- Neovim
- Zsh
- tmux

## Install

### Fedora

```
sudo dnf install git stow neovim zsh tmux
```

### WSL (Ubuntu)

```
sudo apt install git stow neovim zsh tmux
```

Clone the repository:

```
git clone git@github.com:gcotty/dotfiles.git
cd ~/dotfiles
```

Back up any existing configs, then create the symlinks:

```
stow --target="$HOME" nvim zsh tmux
```

## Remove symlinks

```
stow --delete --target="$HOME" nvim zsh tmux
```

## Restow after reorganizing files

```
stow --restow --target="$HOME" nvim zsh tmux
```
