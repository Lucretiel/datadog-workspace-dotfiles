HOME = /home/bits

.PHONY: all

all: install-rust install-configs install-bins install-nix fish-variables

# CARGO STUFF
CARGO_BIN = $(HOME)/.cargo/bin
CARGO = $(CARGO_BIN)/cargo
RUSTC = $(CARGO_BIN)/rustc

.PHONY: install-rust
install-rust: $(CARGO) $(RUSTC)

$(CARGO) $(RUSTC) &: | /usr/bin/curl /usr/bin/dash
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | dash -s -- --default-toolchain stable --no-modify-path -y

# CONFIG STUFF
DOTFILES = $(HOME)/dotfiles

.PHONY: install-configs fish-variables install-bins

install-configs: /usr/bin/stow
	stow --target $(HOME)/.config --dir $(DOTFILES) config

install-bins: /usr/bin/stow
	stow --target $(HOME)/.local/bin --dir $(DOTFILES) bin

fish-variables: /usr/bin/fish
	fish --no-config $(DOTFILES)/variables.fish

# NIX STUFF
NIX_PROFILE = $(HOME)/.nix-profile
NIX_BIN = $(NIX_PROFILE)/bin

.PHONY: install-nix

install-nix: $(NIX_BIN)/nix

$(NIX_BIN)/nix: | /nix /usr/bin/dash /usr/bin/curl
	curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | dash -s -- --no-daemon --yes --no-modify-profile

/nix:
	sudo mkdir -p /nix
	sudo chown bits:root /nix
	sudo chmod 755 /nix

$(NIX_BIN)/%: | $(NIX_BIN)/nix
	$(NIX_BIN)/nix --extra-experimental-features 'nix-command flakes' profile add nixpkgs#$*

# GENERAL UTILITIES
/usr/bin/stow:
	sudo apt install --yes stow

/usr/bin/curl:
	sudo apt install --yes curl

/usr/bin/dash:
	sudo apt install --yes dash

/usr/bin/fish:
	sudo apt install --yes fish
