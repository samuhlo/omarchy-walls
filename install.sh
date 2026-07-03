#!/bin/bash

# Installs omarchy-walls: binary in ~/.local/bin + Hyprland keybinding.
# Idempotent -> safe to re-run after updates.

set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")
BIN_DIR="$HOME/.local/bin"
BINDINGS="$HOME/.config/hypr/bindings.conf"
KEYBIND='bindd = SUPER ALT, W, Wallpaper browser, exec, omarchy-walls menu'

echo ":: omarchy-walls installer"

missing=()
for dep in jq curl fzf gum kitty imv; do
  command -v "$dep" >/dev/null || missing+=("$dep")
done
if ((${#missing[@]})); then
  echo ":: missing dependencies: ${missing[*]}"
  echo "   install them with: omarchy pkg add ${missing[*]}"
  exit 1
fi

command -v omarchy-theme-bg-set >/dev/null ||
  { echo ":: this tool needs an Omarchy system (omarchy-theme-bg-set not found)"; exit 1; }

mkdir -p "$BIN_DIR"
install -m 755 "$SCRIPT_DIR/omarchy-walls" "$BIN_DIR/omarchy-walls"
echo ":: installed $BIN_DIR/omarchy-walls"

if [[ -f $BINDINGS ]] && ! grep -qF "omarchy-walls menu" "$BINDINGS"; then
  # BLINDAJE -> never touch a combo the user already bound to something else
  if grep -qE '^\s*bindd? = SUPER ALT, W,' "$BINDINGS"; then
    echo ":: SUPER+ALT+W is already bound to something else — add your own binding:"
    echo "   $KEYBIND"
  else
    cp "$BINDINGS" "$BINDINGS.bak.$(date +%s)"
    printf '\n# omarchy-walls\n%s\n' "$KEYBIND" >>"$BINDINGS"
    echo ":: keybinding added: SUPER+ALT+W (backup of bindings.conf created)"
    if command -v hyprctl >/dev/null && [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]]; then
      hyprctl reload >/dev/null
      errors=$(hyprctl configerrors)
      [[ -z $errors || $errors == "no errors" ]] || echo ":: hyprland config errors: $errors"
    fi
  fi
elif [[ -f $BINDINGS ]]; then
  echo ":: keybinding already present, skipping"
fi

"$BIN_DIR/omarchy-walls" integrate

echo ":: done — press SUPER+ALT+W or run: omarchy-walls menu"
