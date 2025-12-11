#!/usr/bin/env dash

set -exu

export PATH="$HOME/.cargo/bin:$HOME/.nix-profile/bin:$PATH"

(
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | dash -s -- --default-toolchain stable --no-modify-path -y
) 2>&1 | tee rustup-install.log &

(
  fish "$HOME/dotfiles/variables.fish"
) 2>&1 | tee fish-variables.log &

(
  curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | dash -s -- --no-daemon --yes --no-modify-profile

  nix --extra-experimental-features 'nix-command flakes' profile add $(printf 'nixpkgs#%s ' \
    bacon bat biff bottom broot difftastic dust eza fd fzf hyperfine jq \
    jujutsu neovim procs protobuf ripgrep sd starship stow xh zellij zoxide
  )

  stow --target "$HOME/.config" --dir "$HOME/dotfiles" config
  stow --target "$HOME/.local/bin" --dir "$HOME/dotfiles" bin
) 2>&1 | tee nix-install.log &

wait
