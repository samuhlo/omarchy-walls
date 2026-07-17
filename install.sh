#!/bin/bash

# [FLOW] Re-running repairs updates without duplicating the binding.
# Works from a checkout or a curl pipe:
#   curl -fsSL https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/install.sh | bash

set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/samuhlo/omarchy-walls/main"
BIN_DIR="$HOME/.local/bin"
BINDINGS="$HOME/.config/hypr/bindings.conf"
KEYBIND='bindd = SUPER ALT, W, Wallpaper browser, exec, omarchy-walls menu'

# [FLOW] A curl pipe has no checkout; fetch the binary instead.
SCRIPT_DIR=""
if [[ -n ${BASH_SOURCE[0]:-} && -f ${BASH_SOURCE[0]} ]]; then
  SCRIPT_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
fi

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
if [[ -n $SCRIPT_DIR && -f $SCRIPT_DIR/omarchy-walls ]]; then
  install -m 755 "$SCRIPT_DIR/omarchy-walls" "$BIN_DIR/omarchy-walls"
else
  echo ":: downloading omarchy-walls from GitHub"
  tmp=$(mktemp)
  curl -fsSL "$RAW_BASE/omarchy-walls" -o "$tmp"
  # FAIL CLOSED -> A GitHub error page must never become an executable.
  head -1 "$tmp" | grep -q '^#!/bin/bash' || { rm -f "$tmp"; echo ":: download failed"; exit 1; }
  install -m 755 "$tmp" "$BIN_DIR/omarchy-walls"
  rm -f "$tmp"
fi
echo ":: installed $BIN_DIR/omarchy-walls"

if [[ -f $BINDINGS ]] && ! grep -qF "omarchy-walls menu" "$BINDINGS"; then
  # GUARD -> Preserve a key combination already owned by the user.
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
