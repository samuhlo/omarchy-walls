# PR draft — basecamp/omarchy

Branch ready: `samuhlo/omarchy:feat/wallpaper-browser` →
https://github.com/samuhlo/omarchy/pull/new/feat/wallpaper-browser

---

**Title:** Add wallpaper browser for the dharmx/walls collection

`Style > Background` gains a **󰍉 Browse walls collection** entry: a floating
browser for [dharmx/walls](https://github.com/dharmx/walls) — 1,637 curated
wallpapers in 51 categories — without cloning its 3.7 GB. Browse, preview,
and either set a wallpaper right away or add it to any theme's rotation.

Pick a category, previewed as a mosaic of random samples:

![categories](https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/assets/preview-categories.png)

Fuzzy-search with live image previews:

![browser](https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/assets/preview-list.png)

Set it now, or add it to a theme:

![actions](https://raw.githubusercontent.com/samuhlo/omarchy-walls/main/assets/preview-actions.png)

## How it works

- **Two files:** `bin/omarchy-walls` (self-contained bash, shows up in
  `omarchy commands`) and one entry in the background selector's Lua.
- **Featherweight:** one GitHub API call indexes the collection, previews are
  ~12 KB thumbnails via a resize proxy, and only what you install downloads
  at full size. A whole browsing session costs a few hundred KB.
- **Theme-native:** colors come from the active theme's `colors.toml` and the
  session's gum styling; the entry's cover is drawn in the theme accent and
  regenerates on theme change.

## One dependency to discuss

Everything used is already a base package except **kitty**, which provides
the graphics protocol for inline previews. Without it, the entry sends a
notification pointing to `omarchy pkg add kitty` instead of failing silently.
Happy to take this wherever you prefer — gating the entry, adding kitty, or
another direction.

## Thanks

All the wallpapers belong to their artists and to the beautiful curation work
of [@dharmx](https://github.com/dharmx) in
[dharmx/walls](https://github.com/dharmx/walls) — this tool just gives that
collection a comfortable home inside Omarchy, downloading on demand and
redistributing nothing.
