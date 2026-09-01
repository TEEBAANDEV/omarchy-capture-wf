# omarchy-screenrecorder

**English** · [Español](#espa%C3%B1ol)

> Screen recording for Hyprland/Omarchy that **won't crash your AMD VCE GPU.**

Works where `gpu-screen-recorder` is unusable: on Polaris (RX 500-series) cards
it initializes the hardware encoder, the kernel ring buffer times out
(`ring vce0 timeout` → GPU reset → freeze). This project records with
**CPU-encoded h264 (libx264 via [wf-recorder](https://github.com/ammen99/wf-recorder))**
so the GPU encoder is never touched.

Built for and tested on Omarchy (Hyprland + Quickshell).

---

## Features

- **Toggle recording** — one bind to start/stop (`record-screen`).
- **Region picker across all monitors** — `--region` freezes the whole desktop
  (via `hyprpicker`) and lets you click any monitor or visible window to snap to
  it, or drag a free rectangle. Works across multiple monitors, unlike the
  built-in trigger (`--region` clips to the active workspace).
- **Multi-track audio** — desktop and mic are captured as **separate named AAC
  tracks**, plus an optional unified mix, so you can mute/split either source
  when editing.
- **Bar indicator** — shows a recording icon and doubles as a start/stop toggle.
- **Menu integration** — Start/Stop entries under *Capture → Screenrecord*.
- Video uses `wf-recorder` with **no audio**, so no fragile PipeWire
  loopback/null-sink mixing is involved.

## Requirements

- `wf-recorder`, `ffmpeg`, `slurp`, `hyprpicker`, `jq`, `sed`
- Hyprland + the Omarchy shell/Quickshell and `omarchy-notification-send`.

## Install

```bash
git clone https://github.com/<you>/omarchy-screenrecorder.git
cd omarchy-screenrecorder
./install.sh
```

Idempotent — safe to re-run. Installs:

| Component | Destination |
|---|---|
| `record-screen` / `record-screen-daemon` | `~/.local/bin` |
| Bar indicator plugin | `~/.config/omarchy/plugins/<user>.indicators/` |
| Menu override (Start/Stop) | `~/.config/omarchy/extensions/` |
| Proxy `omarchy-capture-screenrecording` | `~/.config/omarchy/bin/` |
| PATH override | `~/.config/environment.d/` |

> **Note:** the `environment.d` PATH override only applies on your **next
> login**, because the running Quickshell ignores mid-session PATH changes. If
> the bar doesn't pick up the proxy, log out and back in.

### Keybindings

Add to `~/.config/hypr/bindings.lua` (absolute paths so they work even before
the new PATH is active):

```lua
o.bind("SUPER + SHIFT + R", "Screen recording toggle", "~/.local/bin/record-screen")
o.bind("SUPER + SHIFT + ALT + R", "Screen recording region", "~/.local/bin/record-screen --region")
```

Validate with `hyprctl reload` and `hyprctl configerrors`.

## Usage

```bash
record-screen                 # toggle recording of the focused monitor
record-screen --region        # pick a region / monitor / window, then record
record-screen --audio mic     # only the microphone track (default: both)
```

| Flag | Value | Tracks produced |
|------|-------|-----------------|
| `--audio both` (default) | desktop + mic | `Desktop`, `Microphone`, `Mix` |
| `--audio desktop` | desktop only | `Desktop` |
| `--audio mic` | mic only | `Microphone` |
| `--audio none` | video only | — |

Outputs `rec-YYYY-MM-DD_HH-MM-SS.mkv` in `$XDG_VIDEOS_DIR` (`~/Videos`). MKV is
used because it carries multiple audio tracks cleanly; the tracks are named and
show up in mpv/VLC/editors.

A notification confirms start immediately; a critical notification reports a
failed start ~3 s later.

## Configuration

Audio endpoints are **auto-detected** from your PipeWire session:

- **Desktop** → `.monitor` of the default sink.
- **Microphone** → the default source (skips `.monitor` outputs automatically).

You can pin them explicitly with environment variables (useful if auto-detect
picks the wrong device):

```bash
export RECORD_DESK_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
export RECORD_MIC_SOURCE="alsa_input.usb-Your_Mic-00.mono-fallback"
```

Find the names with:

```bash
pactl list short sinks    # pick "*.monitor" of your default output
pactl list short sources
```

## How the audio works

Both endpoints are captured **directly** with `ffmpeg` (no PipeWire loopback
magic), video is captured separately with `wf-recorder`, and everything is
muxed into one MKV when you stop. For `both`, the `Mix` track is built on the
fly with an `asplit`/`amix` filter graph.

## Troubleshooting

**Recording icon doesn't appear in the bar.** Re-scan plugins:
`omarchy-shell shell rescanPlugins`, then add the `<user>.indicators` widget to
your bar layout (it hot-reloads on save).

**Menu still shows gpu-screen-recorder entries.** The proxy only wins when
`~/.config/omarchy/bin` is ahead of `/usr/share/omarchy/bin` in `PATH` — apply
the `environment.d` override by logging out/in.

**Nothing recorded / zero-byte output.** Check `wf-recorder`/`ffmpeg` stderr:
`record-screen` redirects the daemon to `$XDG_RUNTIME_DIR/record-screen-daemon.log`.

## Uninstall

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -rf ~/.config/omarchy/plugins/<user>.indicators
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc  # only the screenrecord keys
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

Revert the two keybindings. Restart the session to release the PATH change.

## License

MIT

---

# <a name="español"></a>Español

> Grabación de pantalla para Hyprland/Omarchy que **no crashea tu GPU AMD VCE.**

Funciona donde `gpu-screen-recorder` es inutilizable: en tarjetas Polaris (serie
RX 500) inicializa el encoder por hardware, el ring buffer del kernel se agota
(`ring vce0 timeout` → reset de GPU → congelación). Este proyecto graba con
**h264 por CPU (libx264 vía [wf-recorder](https://github.com/ammen99/wf-recorder))**
de modo que el encoder de la GPU nunca se toca.

Construido y probado en Omarchy (Hyprland + Quickshell).

---

## Características

- **Toggle de grabación** — un atajo para iniciar/detener (`record-screen`).
- **Selector de región entre todos los monitores** — `--region` congela todo el
  escritorio (con `hyprpicker`) y permite hacer clic en cualquier monitor o
  ventana visible para ajustarse a él, o arrastrar un rectángulo libre.
  Funciona en varios monitores, a diferencia del trigger integrado
  (`--region` se limita al workspace activo).
- **Audio multipista** — escritorio y micro se capturan como **pistas AAC
  nombradas separadas**, más una pista de mezcla unificada opcional, para poder
  silenciar/separar cualquiera de las dos al editar.
- **Indicador en la barra** — muestra el icono de grabación y funciona como
  toggle de iniciar/detener.
- **Integración con el menú** — entradas Iniciar/Detener en *Captura → Grabación
  de pantalla*.
- El video usa `wf-recorder` **sin audio**, evitando el frágil mezclado por
  loopback/PipeWire.

## Requisitos

- `wf-recorder`, `ffmpeg`, `slurp`, `hyprpicker`, `jq`, `sed`
- Hyprland + el shell Omarchy/Quickshell y `omarchy-notification-send`.

## Instalación

```bash
git clone https://github.com/<tu-usuario>/omarchy-screenrecorder.git
cd omarchy-screenrecorder
./install.sh
```

Idempotente — seguro de re-ejecutar. Instala:

| Componente | Destino |
|---|---|
| `record-screen` / `record-screen-daemon` | `~/.local/bin` |
| Plugin del indicador de barra | `~/.config/omarchy/plugins/<usuario>.indicators/` |
| Override del menú (Iniciar/Detener) | `~/.config/omarchy/extensions/` |
| Proxy `omarchy-capture-screenrecording` | `~/.config/omarchy/bin/` |
| Override de PATH | `~/.config/environment.d/` |

> **Nota:** el override de PATH en `environment.d` solo aplica en tu **próximo
> inicio de sesión**, porque el Quickshell en ejecución ignora los cambios de
> PATH a mitad de sesión. Si la barra no toma el proxy, cierra sesión y vuelve
> a entrar.

### Atajos de teclado

Añade a `~/.config/hypr/bindings.lua` (rutas absolutas para que funcionen antes
de que el nuevo PATH esté activo):

```lua
o.bind("SUPER + SHIFT + R", "Screen recording toggle", "~/.local/bin/record-screen")
o.bind("SUPER + SHIFT + ALT + R", "Screen recording region", "~/.local/bin/record-screen --region")
```

Valida con `hyprctl reload` y `hyprctl configerrors`.

## Uso

```bash
record-screen                 # toggle de grabación del monitor enfocado
record-screen --region        # elige región / monitor / ventana y graba
record-screen --audio mic     # solo la pista del micro (por defecto: both)
```

| Flag | Valor | Pistas producidas |
|------|-------|-------------------|
| `--audio both` (predeterminado) | escritorio + micro | `Desktop`, `Microphone`, `Mix` |
| `--audio desktop` | solo escritorio | `Desktop` |
| `--audio mic` | solo micro | `Microphone` |
| `--audio none` | solo video | — |

Genera `rec-YYYY-MM-DD_HH-MM-SS.mkv` en `$XDG_VIDEOS_DIR` (`~/Videos`). Se usa
MKV porque soporta varias pistas de audio limpiamente; las pistas van nombradas
y aparecen en mpv/VLC/editores.

Una notificación confirma el inicio al instante; si falla el arranque, una
notificación crítica lo comunica ~3 s después.

## Configuración

Los endpoints de audio se **detectan automáticamente** desde tu sesión PipeWire:

- **Escritorio** → `.monitor` del sink predeterminado.
- **Micro** → el source predeterminado (omite automáticamente las salidas
  `.monitor`).

Puedes fijarlos explícitamente con variables de entorno (útil si la
auto-detección elige el dispositivo equivocado):

```bash
export RECORD_DESK_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
export RECORD_MIC_SOURCE="alsa_input.usb-Tu_Micro-00.mono-fallback"
```

Encuentra los nombres con:

```bash
pactl list short sinks    # elige "*.monitor" de tu salida predeterminada
pactl list short sources
```

## Cómo funciona el audio

Ambos endpoints se capturan **directamente** con `ffmpeg` (sin loopbacks de
PipeWire), el video se captura aparte con `wf-recorder`, y todo se multiplexa en
un solo MKV al detener. En modo `both`, la pista `Mix` se construye al vuelo con
un filtro `asplit`/`amix`.

## Solución de problemas

**El icono de grabación no aparece en la barra.** Re-escanea plugins:
`omarchy-shell shell rescanPlugins`, y añade el widget `<usuario>.indicators` a
tu barra (se recarga en caliente al guardar).

**El menú aún muestra entradas de gpu-screen-recorder.** El proxy solo gana si
`~/.config/omarchy/bin` está antes que `/usr/share/omarchy/bin` en `PATH` —
aplica el override de `environment.d` cerrando sesión y volviendo a entrar.

**No se graba nada / archivo de cero bytes.** Revisa el stderr de
`wf-recorder`/`ffmpeg`: `record-screen` redirige el daemon a
`$XDG_RUNTIME_DIR/record-screen-daemon.log`.

## Desinstalación

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -rf ~/.config/omarchy/plugins/<usuario>.indicators
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc  # solo las claves de screenrecord
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

Deshaz los dos atajos y reinicia la sesión para liberar el cambio de PATH.

## Licencia

MIT