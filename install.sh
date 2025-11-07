#!/usr/bin/env sh

set -exu

export PATH="$HOME/.cargo/bin:$PATH"

export APT_PACKAGES="fzf neovim stow"
export CARGO_PACKAGES="bat bottom broot du-dust eza fd-find hurl hyperfine jj-cli procs ripgrep sd starship zellij zoxide"

(
  set -exu

  sudo apt update --yes
  sudo apt install --yes $APT_PACKAGES
  sudo apt upgrade --yes

  stow --target "$HOME/.config" --dir "$HOME/dotfiles" config
) &

(
  set -exu
  
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --no-modify-path -y
  cargo install --locked $CARGO_PACKAGES
) &

wait
