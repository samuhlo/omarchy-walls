# PR draft — basecamp/omarchy

Branch ready: `samuhlo/omarchy:feat/wallpaper-browser` →
https://github.com/samuhlo/omarchy/pull/new/feat/wallpaper-browser

---

**Title:** Add wallpaper browser for the dharmx/walls collection

## What

`Style > Background` gains a **󰍉 Browse walls collection** entry that opens a
floating browser for [dharmx/walls](https://github.com/dharmx/walls) — 1,637
curated wallpapers in 51 categories. Pick a category (previewed as a 2×2
mosaic of random samples), fuzzy-search with live image previews, and either
set a wallpaper as the current background or add it to any theme's rotation
through the standard `~/.config/omarchy/backgrounds/<theme>/` folders.

![categories](https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/assets/preview-categories.png)
![browser](https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/assets/preview-list.png)
![actions](https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/assets/preview-actions.png)

## How

- **No 3.7 GB clone.** One GitHub Trees API call builds a weekly-cached index;
  thumbnails come through an image-resize proxy at ~12 KB each; only installed
  wallpapers download at full size. A browsing session costs a few hundred KB.
- **Theme-native.** fzf colors come from the active theme's `colors.toml`, gum
  picks up the session-wide styling Omarchy already injects, and the menu
  entry's cover (a magnifier drawn in the theme accent) regenerates on theme
  change.
- **Two files.** `bin/omarchy-walls` (self-contained bash, follows the
  `omarchy:summary` conventions, so it shows up in `omarchy commands`) and one
  entry appended to `default/elephant/omarchy_background_selector.lua`.

## Dependencies

Everything is a base package (`jq`, `curl`, `fzf`, `gum`, `imv`,
`imagemagick`) **except kitty**, which provides the graphics protocol for
inline image previews. Without kitty the entry sends a notification pointing
to `omarchy pkg add kitty` instead of failing silently. Happy to discuss:
adding kitty to base, gating the menu entry on kitty being installed, or any
other direction.

## Provenance

Developed and battle-tested standalone at
https://github.com/samuhlo/omarchy-walls (curl-installable for anyone who
wants it without the PR). Wallpaper images belong to their artists, curated
upstream by dharmx — this tool downloads on demand and redistributes nothing.
