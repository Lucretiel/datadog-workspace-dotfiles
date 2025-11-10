#!/usr/bin/env sh

set -exu

export PATH="$HOME/.cargo/bin:$PATH"

export INSTALL_APT_PACKAGES="fzf neovim stow"
export INSTALL_CARGO_PACKAGES="bat bottom broot du-dust eza fd-find xh hyperfine jj-cli procs ripgrep sd starship zellij zoxide"
export CARGO_TARGET_DIR="$HOME/.local/state/cargo-dotfiles/target"

(
  sudo apt update --yes
  sudo apt install --yes $INSTALL_APT_PACKAGES
  sudo apt upgrade --yes

  stow --target "$HOME/.config" --dir "$HOME/dotfiles" config
) 2>&1 | tee apt-installs.log &

(
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --no-modify-path -y
  mkdir -p "$CARGO_TARGET_DIR"
  cargo install --locked cargo-binstall
  cargo binstall --locked -y $INSTALL_CARGO_PACKAGES
) 2>&1 | tee cargo-installs.log &

fish "$HOME/dotfiles/variables.fish" 2>&1 | tee fish-variables.log &

wait
