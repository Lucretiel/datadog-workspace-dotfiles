#!/usr/bin/env sh

set -exu

exec make -j -f ~/dotfiles/INSTALL.mak all
