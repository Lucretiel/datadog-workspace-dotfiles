HOME = /home/bits

.PHONY: all

all: install-rust install-configs install-nix fish-variables

# CARGO STUFF
CARGO_BIN = $(HOME)/.cargo/bin
CARGO = $(CARGO_BIN)/cargo
RUSTC = $(CARGO_BIN)/rustc

.PHONY: install-rust
install-rust: $(CARGO) $(RUSTC)

$(CARGO) $(RUSTC) &: /usr/bin/curl /usr/bin/dash
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | dash -s -- --default-toolchain stable --no-modify-path -y

# CONFIG STUFF
CONFIG = $(HOME)/.config
DOTFILES = $(HOME)/dotfiles

.PHONY: install-configs fish-variables

install-configs: /usr/bin/stow
	stow --target $(CONFIG) --dir $(DOTFILES) config

fish-variables: /usr/bin/fish
	fish $(DOTFILES)/variables.fish

# NIX STUFF
NIX_PROFILE = $(HOME)/.nix-profile
NIX_BIN = $(HOME)/bin

.PHONY: install-nix

install-nix: $(NIX_BIN)/nix

$(NIX_BIN)/nix: /nix /usr/bin/dash /usr/bin/curl
	curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | dash -s -- --no-daemon --yes --no-modify-profile

/nix:
	sudo mkdir -p /nix
	sudo chown bits:root /nix
	sudo chmod 755 /nix

# GENERAL UTILITIES
/usr/bin/stow:
	sudo apt install --yes stow

/usr/bin/curl:
	sudo apt install --yes curl

/usr/bin/dash:
	sudo apt install --yes dash

/usr/bin/fish:
	sudo apt install --yes fish
