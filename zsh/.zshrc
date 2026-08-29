  # Neovim
  if [[ -d /opt/nvim-linux-x86_64/bin ]]; then
    path=(/opt/nvim-linux-x86_64/bin $path)
  fi

  # Prevent duplicate PATH entries
  typeset -U path PATH

  # NVM
  export NVM_DIR="$HOME/.nvm"

  [[ -s "$NVM_DIR/nvm.sh" ]] &&
    source "$NVM_DIR/nvm.sh"

  [[ -s "$NVM_DIR/bash_completion" ]] &&
    source "$NVM_DIR/bash_completion"

  # Starship
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi

  # uv
  [[ -r "$HOME/.local/bin/env" ]] &&
    source "$HOME/.local/bin/env"

  # Rust
  [[ -r "$HOME/.cargo/env" ]] &&
    source "$HOME/.cargo/env"
