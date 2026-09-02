# ------------------
# ---- Env vars ----
# ------------------
export EDITOR=nvim
export VISUAL=nvim

# NVM
export NVM_DIR="$HOME/.nvm"

# ------------------
# ------ Path ------
# ------------------
# Neovim
if [[ -d /opt/nvim-linux-x86_64/bin ]]; then
  path=(/opt/nvim-linux-x86_64/bin $path)
fi

[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)

typeset -U path PATH

# -------------------
# ---- Tool init ----
# -------------------
# NVM
[[ -s "$NVM_DIR/nvm.sh" ]] &&
  source "$NVM_DIR/nvm.sh"

[[ -s "$NVM_DIR/bash_completion" ]] &&
  source "$NVM_DIR/bash_completion"

# uv
[[ -r "$HOME/.local/bin/env" ]] &&
  source "$HOME/.local/bin/env"

# Rust
[[ -r "$HOME/.cargo/env" ]] &&
  source "$HOME/.cargo/env"

# Starship
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

autoload -Uz compinit && compinit

# ------------------
# ---- History -----
# ------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# ------------------
# ---- Aliases -----
# ------------------
# Set file type colors
if [[ -x /usr/bin/dircolors ]]; then
  if [[ -r ~/.dircolors ]]; then
    eval "$(dircolors -b ~/.dircolors)"
  else
    eval "$(dircolors -b)"
  fi

  alias ls='ls --color=auto'
  alias ll='ls -lah --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'

  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

alias v='source .venv/bin/activate'

# direnv hook
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Private config load
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Prevent nvim editing from applying to shell prompts
bindkey -e
