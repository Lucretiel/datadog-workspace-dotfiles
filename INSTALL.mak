HOME = /home/bits
DOTFILES = $(HOME)/dotfiles
CONFIG_SOURCE=$(DOTFILES)/config
CONFIG = $(HOME)/.config
LOCAL = $(HOME)/.local
BIN = $(LOCAL)/bin

# INITIAL STUFF
.PHONY: all

all: all-apt all-cargo config

# APT STUFF
.PHONY: apt-update all-apt

all-apt: /usr/bin/fzf /usr/bin/nvim

apt-update:
	sudo apt update --yes

/usr/bin/fzf: apt-update
	sudo apt install --yes fzf

/usr/bin/nvim: apt-update
	sudo apt install --yes neovim

/usr/bin/stow: apt-update
	sudo apt install --yes stow

/usr/bin/curl: apt-update
	sudo apt install --yes curl

# CARGO STUFF
# TODO: find a better package manager for these, so that we get man pages and
# shell completions and stuff like that.
CARGO_BIN = $(HOME)/.cargo/bin
CARGO = $(CARGO_BIN)/cargo
RUSTC = $(CARGO_BIN)/rustc
CARGO_INSTALL = $(CARGO) install --locked --quiet

# Left is the name of the binary; right is the name of the rust crate
CARGO_PACKAGES = \
	bat:bat \
	btm:bottom \
	broot:broot \
	dust:dust \
	eza:eza \
	fd:fd-find \
	hurl:hurl \
	hyperfine:hyperfine \
	jj:jj-cli \
	procs:procs \
	rg:ripgrep \
	sd:sd \
	starship:starship \
	zellij:zellij \
	zoxide:zoxide

CARGO_BINS = $(foreach pair,$(CARGO_PACKAGES),$(CARGO_BIN)/$(word 1,$(subst :, ,$(pair))))

.PHONY: all-cargo
all-cargo: $(CARGO_BINS)

$(CARGO) $(RUSTC) &: /usr/bin/curl
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable --no-modify-path -y

$(CARGO_BIN)/%: $(CARGO)
	$(eval package = $(word 2,$(subst :, ,$(filter $*:%,$(CARGO_PACKAGES)))))
	$(CARGO_INSTALL) $(package)

# CONFIG STUFF
.PHONY: config

config: /usr/bin/stow
	stow --target $(CONFIG) --dir $(DOTFILES) config
