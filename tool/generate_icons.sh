#!/usr/bin/env bash
# Rasterises assets/icon/app_icon.svg and regenerates the platform launcher
# icons. Run after editing the SVG, and keep PawMark in
# lib/widgets/app_logo.dart in sync with it.
#
# Inkscape ships as a snap on some distros and is then confined to $HOME, so it
# cannot read this repo if the checkout lives elsewhere (e.g. /mnt). Staging the
# render through a plain, non-hidden directory under $HOME works in both cases.
set -euo pipefail
cd "$(dirname "$0")/.."

stage="$(mktemp -d "${HOME}/rer-icon-XXXXXX")"
trap 'rm -rf "$stage"' EXIT

cp assets/icon/app_icon.svg "$stage/"
inkscape --export-type=png --export-filename="$stage/app_icon.png" \
         --export-width=1024 --export-height=1024 "$stage/app_icon.svg"
cp "$stage/app_icon.png" assets/icon/app_icon.png

dart run flutter_launcher_icons
