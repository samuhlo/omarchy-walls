# omarchy-walls — Buscador e instalador de wallpapers de dharmx/walls para Omarchy

## Viabilidad

**Viable, y con poco código.** Los tres pilares ya existen:

1. **Omarchy ya tiene la API que necesitamos** (verificado en este sistema):
   - `omarchy theme bg set <ruta>` → cambia el fondo **ahora mismo**.
   - `~/.config/omarchy/backgrounds/<NombreTema>/` → carpeta de fondos *de usuario*
     por tema. Cualquier imagen que dejes ahí la recoge automáticamente
     `omarchy theme bg next` (verificado leyendo el fuente de `omarchy-theme-bg-next`).
     Esto cubre el caso "solo agregar a la configuración del tema".
2. **El repo dharmx/walls no hay que clonarlo** (pesa ~3,7 GB). Se consulta con la
   API de GitHub (`git/trees?recursive=1` = 1 sola llamada devuelve el listado
   completo) y cada imagen se descarga individualmente desde
   `raw.githubusercontent.com/dharmx/walls/main/<categoría>/<archivo>`.
   Estructura: ~55 carpetas-categoría (abstract, anime, minimal, nature, nord,
   gruvbox, stalenhag, …), formatos PNG/JPG (+ MP4 en `animated`, fuera de alcance).
3. **UI integrada con Omarchy**: Walker (el launcher de Omarchy) tiene modo dmenu
   con soporte de iconos por entrada → sirve para mostrar *thumbnails* en la lista.
   Para preview a tamaño completo: `imv` (ya instalado) en ventana flotante.

Herramientas disponibles verificadas: walker 2.16.2, imv, fzf, gum, kitty/ghostty.

## Diseño

**Un script Bash** (mismo idioma que las herramientas omarchy-*), instalable en
`~/.local/bin/omarchy-walls`. Sin demonios, sin dependencias raras.

### Flujo de usuario

```
SUPER+SHIFT+W (keybinding)
  └─ Walker: lista de categorías (con nº de imágenes)
       └─ Walker: lista de wallpapers de la categoría (thumbnail como icono)
            └─ Preview a pantalla completa con imv (flotante)
                 └─ Menú de acción (Walker):
                      • Establecer como fondo ahora   → descarga + copia a
                        ~/.config/omarchy/backgrounds/<Tema>/ + omarchy theme bg set
                      • Añadir al tema actual          → solo descarga + copia
                      • Elegir otro tema destino       → lista de temas, copia allí
                      • Volver / Cancelar
```

### Datos y caché (`~/.cache/omarchy-walls/`)

- `index.json` — resultado de `GET /repos/dharmx/walls/git/trees/main?recursive=1`,
  refrescado si tiene >7 días. Una sola llamada API (límite anónimo 60/h, sobra).
- `thumbs/<categoría>/<archivo>.jpg` — thumbnails ~200px. Dos estrategias:
  - **v1 (simple):** descargar bajo demanda vía proxy de redimensionado
    (`images.weserv.nl/?url=raw.githubusercontent.com/...&w=200`) — evita bajar
    imágenes de varios MB solo para el listado.
  - **Fallback sin proxy:** descargar original + `magick -resize 200x` y cachear.
- `full/<categoría>/<archivo>` — originales descargados (también sirven de caché
  para no re-descargar al instalar).

Las descargas desde `raw.githubusercontent.com` no consumen cuota de API.

### Integración con Omarchy (solo zonas seguras)

- Binario en `~/.local/bin/` (ya está en PATH).
- Keybinding en `~/.config/hypr/bindings.conf`:
  `bind = SUPER SHIFT, W, exec, omarchy-walls`
- Regla de ventana flotante para el preview de imv en config de usuario de Hyprland.
- **Nunca** tocar `~/.local/share/omarchy/` (se pierde en cada update).

## Fases de implementación

### Fase 1 — Núcleo CLI (sin UI) ✅ (2026-07-03)
- `omarchy-walls index` : descarga/refresca `index.json`, parsea con `jq`.
- `omarchy-walls list [categoría]` : lista categorías o archivos.
- `omarchy-walls get <cat>/<archivo>` : descarga a caché `full/`.
- `omarchy-walls install <cat>/<archivo> [--set] [--theme <nombre>]` :
  copia a `~/.config/omarchy/backgrounds/<Tema>/` y opcionalmente `bg set`.
- Manejo de errores: sin red, API rate-limit, archivo desaparecido del repo.

### Fase 2 — Preview ✅ (2026-07-03)
- Generación/caché de thumbnails (weserv + fallback magick).
- `omarchy-walls preview <cat>/<archivo>` : imv en ventana flotante centrada.

### Fase 3 — UI interactiva ✅ (2026-07-03) — pivote a plan B
- Walker 2.16 (reescrito en Rust) NO soporta iconos en modo dmenu: el parser de
  stdin solo asigna `item.text` (verificado en `src/main.rs` del repo). Se activó
  el plan B previsto: TUI fzf con preview kitty-graphics.
- Flujo (rediseñado 2026-07-03 tras feedback): selector de **categorías**
  primero (con entrada `all` que engloba todo, contadores por categoría y
  preview de una imagen aleatoria de la categoría) → lista de wallpapers de la
  categoría (solo nombre de archivo, preview en vivo) → menú de acciones con la
  imagen seleccionada renderizada en grande encima (gum): Set now / Add to
  current theme / Add to another theme / Fullscreen preview / Back / Quit.
- Esc navega hacia atrás nivel a nivel (acciones → lista → categorías → salir).
- `omarchy-walls menu` : lanza el browser en kitty flotante centrada (75%),
  pensado para el keybinding de Hyprland.

### Fase 4 — Pulido ✅ (2026-07-03)
- Búsqueda global: cubierta por la categoría `all` del selector.
- Notificaciones `notify-send` al instalar y al establecer fondo.
- UI tematizada con la paleta Carbon Vandal (amarillo `#FFCA40` en prompt,
  cursor y acentos de fzf/gum).
- `install.sh`: binario a `~/.local/bin`, keybinding `SUPER+ALT+W` (comprueba
  colisiones antes de tocar `bindings.conf`, con backup), idempotente.
- README (estilo propio) + capturas reales en `assets/`.
- Publicado en https://github.com/samuhlo/omarchy-walls

## Riesgos / decisiones

| Riesgo | Mitigación |
|---|---|
| Thumbnails lentos la primera vez que abres una categoría | Caché persistente + descarga paralela + proxy de resize |
| Walker podría no escalar bien iconos grandes en listas largas | Probar en Fase 3; plan B: TUI fzf con preview kitty-graphics en ghostty/kitty flotante |
| Repo sin licencia (imágenes de artistas varios) | Uso personal OK; no redistribuir las imágenes con el proyecto |
| Categoría `animated` (MP4) | Excluida en v1 (swaybg no reproduce vídeo) |
| Rate limit API GitHub (60/h anónimo) | Solo 1 llamada por refresco de índice; soporte opcional de `GITHUB_TOKEN` |

## Dependencias

Ya instaladas: `walker`, `imv`, `jq` (verificar), `curl`, `notify-send`.
Opcional: `imagemagick` (fallback de thumbnails).
