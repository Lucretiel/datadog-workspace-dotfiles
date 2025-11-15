set -Ux EDITOR nvim
set -Ux LESS iMR
set -Ux STARSHIP_SHELL fish
set -Ux EZA_ICONS_AUTO 1
set -Ux SSH_AUTH_SOCK ~/.ssh/ssh_auth_sock
set -U fish_user_paths ~/.local/bin ~/.cargo/bin ~/.nix-profile/bin /nix/var/nix/profiles/default/bin
set -Ux --path XDG_DATA_DIRS ~/.local/share ~/.nix-profile/share /nix/var/nix/profiles/default/share /usr/local/share /usr/share
