# omarchy-capture-wf (v1.1)

[English](#english) · [Español](#espa%C3%B1ol)

A custom adaptation of a screen recorder and Replay Buffer / Clips mode for Hyprland/Omarchy, designed to avoid AMD VCE GPU crashes on affected cards while keeping the workflow simple and native to the desktop environment.

> Built for Omarchy (Hyprland + Quickshell) and optimized for hardware setups where `gpu-screen-recorder` fails because of VCE encoder instability.

## Quick start

```bash
git clone https://github.com/TEEBAANDEV/omarchy-capture-wf.git
cd omarchy-capture-wf
chmod +x install.sh
./install.sh
```

Then use:

```bash
record-screen                           # toggle manual screen recording
record-screen --region                  # record region
record-screen-clip                      # save instant replay clip (SUPER + F10)
record-screen-clip-daemon toggle        # toggle replay buffer (SUPER + SHIFT + F10)
```

> Note: the plugin name in this project is generated from your local Linux username. All commands below use `$(id -un)` so they work as-is when you paste them into a shell. For example, that makes the plugin path `~/.config/omarchy/plugins/<your-name>.indicators/`.

---

## English

### Overview

This project exists because `gpu-screen-recorder` can become unusable on AMD Polaris cards such as the RX 500 series. In those systems, the hardware encoder can trigger kernel ring buffer timeouts (`ring vce0 timeout`), causing GPU resets and desktop freezes.

To avoid that, `omarchy-capture-wf` records video with CPU-based H.264 using `wf-recorder` and `libx264`, so the GPU encoder is never used. Audio is captured separately and muxed into a single MKV file with multiple named tracks.

In Version 1.1, it includes an instant **Replay Buffer / Clips mode** (similar to Instant Replay), allowing you to continuously buffer video in RAM and save clips on demand.

### Why this project is useful

- Avoids unstable AMD VCE encoder usage.
- Works well in Omarchy/Hyprland workflows.
- Includes an interactive bar indicator with live controls and settings locking.
- Supports instant Replay Buffer clips saving and custom region buffer modes.
- Supports region capture across multi-monitors.
- Produces multi-track audio output for editing and post-production.

### Features

- Instant Replay Buffer / Clips mode saved in RAM and exported to `~/Videos/Clips/` via `SUPER + F10`
- Screen and Region Replay Buffer capture modes
- Toggle manual recording with a single command: `record-screen`
- Region capture with `--region` using `hyprpicker`
- Multi-monitor support for region selection
- Configurable audio modes (`both`, `desktop`, `mic`, `none`)
- Multi-track audio mapping in `both` mode (`Track 1=Mix`, `Track 2=Desktop`, `Track 3=Microphone`)
- Interactive Omarchy bar widget indicator with QML dark theme (`qs.Ui`), FPS selectors (30/60), duration chips, and settings locking
- Menu entries under Capture -> Screenrecord
- Recording output stored as MKV for clean multi-track handling

> Note / Warning (v1.1): In Replay Buffer / Clips mode with multi-track audio (`both`), Track 1 currently outputs desktop audio only, and Track 3 outputs microphone audio. This issue is being investigated and will be addressed in a future update.

### Requirements

- `wf-recorder`
- `ffmpeg`
- `slurp`
- `hyprpicker`
- `jq`
- `sed`
- Hyprland + Omarchy shell/Quickshell
- `omarchy-notification-send`

### Installation

```bash
git clone https://github.com/TEEBAANDEV/omarchy-capture-wf.git
cd omarchy-capture-wf
chmod +x install.sh
./install.sh
```

If you are installing your own GitHub fork, replace `TEEBAANDEV` with your GitHub username, for example:

```bash
git clone https://github.com/<your-user>/omarchy-capture-wf.git
```

The installer is idempotent and safe to re-run. It creates the following components, asks the running shell to add the indicator widget to the bar using your local Linux username (that is, `omarchy bar put $(id -un).indicators`), and appends the keybindings below to `~/.config/hypr/bindings.lua` **only if** they are not already present:

| Component | Destination |
| --- | --- |
| `record-screen` / `record-screen-daemon` | `~/.local/bin` |
| `record-screen-clip` / `record-screen-clip-daemon` | `~/.local/bin` |
| `record-screen-config-helper` | `~/.local/bin` |
| Bar indicator plugin | `~/.config/omarchy/plugins/$(id -un).indicators/` |
| Menu override (Start/Stop) | `~/.config/omarchy/extensions/` |
| Proxy `omarchy-capture-screenrecording` | `~/.config/omarchy/bin/` |
| PATH override | `~/.config/environment.d/` |

> Note: use your local Linux username in `~/.config/omarchy/plugins/$(id -un).indicators/`, not your GitHub username. Let `$(id -un)` do the substitution for you.
>
> The `environment.d` PATH override takes effect on the next login because the active Quickshell session does not reload `PATH` changes mid-session. If the bar indicator does not detect the proxy, log out and log back in.

### Keybindings

These are added by the installer when absent, so **no manual step is needed**:

| Shortcut | Action |
| --- | --- |
| `SUPER + F10` | Save Instant Replay Clip (last N seconds) |
| `SUPER + SHIFT + F10` | Toggle Replay Buffer Daemon |
| `SUPER + SHIFT + R` | Toggle Full-Screen Manual Recording |
| `SUPER + SHIFT + ALT + R` | Toggle Region Manual Recording |

To verify keybindings written to your config:

```bash
grep "record-screen" ~/.config/hypr/bindings.lua
```

Then reload the config:

```bash
hyprctl reload
hyprctl configerrors
```

### Usage

```bash
record-screen                             # toggle manual recording of the focused monitor
record-screen --region                    # choose a region, monitor, or window and record
record-screen-clip                        # save last N seconds clip to ~/Videos/Clips/
record-screen-clip-daemon toggle          # toggle background replay buffer
```

| Flag | Value | Output tracks |
| --- | --- | --- |
| `--audio both` (default) | desktop + mic | `Track 1=Mix`, `Track 2=Desktop`, `Track 3=Microphone` |
| `--audio desktop` | desktop only | `Desktop` |
| `--audio mic` | mic only | `Microphone` |
| `--audio none` | video only | — |

Manual recordings are saved as `rec-YYYY-MM-DD_HH-MM-SS.mkv` in `~/Videos`. Replay Buffer clips are saved as `Clip_YYYY-MM-DD_HH-MM-SS.mkv` in `~/Videos/Clips`. MKV is used because it cleanly supports multiple audio tracks while keeping them named and easy to edit in tools such as VLC, mpv, and video editors.

### Configuration

Configuration settings are stored in `~/.config/omarchy-screenrecorder/config.sh` and can be managed interactively from the bar widget:

```bash
CLIP_DURATION=30
CLIP_DIR="$HOME/Videos/Clips"
REC_FPS=60
REC_CRF=20
REC_PRESET="veryfast"
REC_AUDIO_MODE="both"
CLIP_HOTKEY="SUPER + F10"
```

Audio devices are auto-detected from the active PipeWire session:

- Desktop audio uses the default sink monitor output or active USB headset.
- Microphone uses the default source, while ignoring monitor-type outputs automatically.

You can force specific endpoints with environment variables:

```bash
export RECORD_DESK_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
export RECORD_MIC_SOURCE="alsa_input.usb-Your_Mic-00.mono-fallback"
```

To find the relevant names:

```bash
pactl list short sinks
pactl list short sources
```

### How audio is handled

Audio and video are captured separately. The desktop and mic inputs are captured with `ffmpeg` or `pactl` loopbacks, while the video stream is recorded with `wf-recorder`. On stop or clip save, the streams are muxed into a single MKV. For `both` mode, 3 tracks are generated: `Track 1=Mix`, `Track 2=Desktop`, and `Track 3=Microphone`.

### Troubleshooting

**The recording icon does not appear in the bar.**

If it was missing when the installer ran, add it manually:

```bash
omarchy bar put "$(id -un).indicators" --section center --before omarchy.clock
```

Then rescan plugins: `omarchy-shell shell rescanPlugins`. The widget hot-reloads on save.

**The menu still shows `gpu-screen-recorder` entries.**

The proxy only takes precedence when `~/.config/omarchy/bin` is ahead of `/usr/share/omarchy/bin` in your `PATH`. Log out and log back in so the environment override is applied.

**Nothing is recorded or the output is zero bytes.**

Check the daemon logs:

```bash
$XDG_RUNTIME_DIR/record-screen-daemon.log
```

### Uninstall

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -f ~/.local/bin/record-screen-clip ~/.local/bin/record-screen-clip-daemon ~/.local/bin/record-screen-config-helper
rm -rf ~/.config/omarchy/plugins/"$(id -un).indicators"
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

Also remove the keybindings from `~/.config/hypr/bindings.lua` and restart the session.

### License

MIT

---

## Español

### Visión general

Este proyecto es una adaptación personalizada para resolver un problema real: `gpu-screen-recorder` puede resultar inutilizable en tarjetas AMD Polaris, como la serie RX 500. En esos equipos, el encoder de hardware puede disparar timeouts del buffer del kernel (`ring vce0 timeout`), provocando reinicios de la GPU y congelaciones del sistema.

Para evitarlo, `omarchy-capture-wf` graba video con H.264 basado en CPU usando `wf-recorder` y `libx264`, de modo que el encoder de la GPU nunca se utiliza. El audio se captura por separado y se mezcla en un único archivo MKV con varias pistas nombradas.

En la versión 1.1, incluye el **modo Clips / Replay Buffer instantáneo** (almacenamiento en RAM), permitiendo guardar los últimos segundos en cualquier momento.

### Por qué este proyecto es útil

- Evita el uso del encoder AMD VCE inestable.
- Encaja bien con flujos de trabajo de Omarchy/Hyprland.
- Incluye un indicador en la barra interactivo con bloqueo de ajustes.
- Soporta guardado de clips instantáneo y modos de buffer por región.
- Soporta grabación por región en varios monitores.
- Genera audio multipista para edición y postproducción.

### Características

- Modo Clips / Replay Buffer instantáneo en RAM exportable a `~/Videos/Clips/` vía `SUPER + F10`
- Modos de buffer por pantalla completa o por región
- Grabación manual con un solo comando: `record-screen`
- Captura por región con `--region` usando `hyprpicker`
- Soporte para varios monitores al seleccionar la región
- Modos de audio configurables (`both`, `desktop`, `mic`, `none`)
- Grabación de audio multipista en modo `both` (`Pista 1=Mezcla`, `Pista 2=Escritorio`, `Pista 3=Micrófono`)
- Indicador interactivo en la barra de Omarchy con tema oscuro (`qs.Ui`), selector de FPS (30/60), chips de duración y bloqueo de ajustes
- Entradas en el menú Captura -> Screenrecord
- Salida en MKV para manejar varias pistas de forma limpia

> Nota / Advertencia (v1.1): En el modo Replay Buffer / Clips con audio multipista (`both`), la Pista 1 emite actualmente solo el audio del escritorio y la Pista 3 emite el micrófono. Este comportamiento se corregirá en una próxima actualización.

### Requisitos

- `wf-recorder`
- `ffmpeg`
- `slurp`
- `hyprpicker`
- `jq`
- `sed`
- Hyprland + shell Omarchy/Quickshell
- `omarchy-notification-send`

### Instalación

```bash
git clone https://github.com/TEEBAANDEV/omarchy-capture-wf.git
cd omarchy-capture-wf
chmod +x install.sh
./install.sh
```

Si usas un fork o un repositorio con otro nombre de usuario, cambia la parte del propietario en la URL:

```bash
git clone https://github.com/<tu-usuario>/omarchy-capture-wf.git
```

El instalador es idempotente y se puede ejecutar varias veces sin problemas. Crea los siguientes componentes, pide al shell activo que añada el widget del indicador a la barra usando tu usuario local de Linux (`omarchy bar put $(id -un).indicators`) y añade los atajos a `~/.config/hypr/bindings.lua` **solo si** no están ya presentes:

| Componente | Destino |
| --- | --- |
| `record-screen` / `record-screen-daemon` | `~/.local/bin` |
| `record-screen-clip` / `record-screen-clip-daemon` | `~/.local/bin` |
| `record-screen-config-helper` | `~/.local/bin` |
| Plugin del indicador de barra | `~/.config/omarchy/plugins/$(id -un).indicators/` |
| Override del menú (Iniciar/Detener) | `~/.config/omarchy/extensions/` |
| Proxy `omarchy-capture-screenrecording` | `~/.config/omarchy/bin/` |
| Override de PATH | `~/.config/environment.d/` |

> Nota: el override de `environment.d` se aplica en el próximo inicio de sesión porque el Quickshell activo no recarga cambios de `PATH` en mitad de sesión. Si el indicador no detecta el proxy, cierra sesión y vuelve a entrar.

### Atajos de teclado

| Atajo | Acción |
| --- | --- |
| `SUPER + F10` | Guardar Clip Instantáneo (últimos N segundos) |
| `SUPER + SHIFT + F10` | Alternar Demonio de Replay Buffer |
| `SUPER + SHIFT + R` | Alternar Grabación Manual (Pantalla Completa) |
| `SUPER + SHIFT + ALT + R` | Alternar Grabación Manual (Región / Zona) |

Para ver las líneas exactas escritas:

```bash
grep "record-screen" ~/.config/hypr/bindings.lua
```

Luego recarga la configuración:

```bash
hyprctl reload
hyprctl configerrors
```

### Uso

```bash
record-screen                             # activa o pausa la grabación del monitor activo
record-screen --region                    # elige una región, un monitor o una ventana y graba
record-screen-clip                        # guarda el clip de los últimos N segundos
record-screen-clip-daemon toggle          # activa o desactiva el buffer en segundo plano
```

| Opción | Valor | Pistas generadas |
| --- | --- | --- |
| `--audio both` (predeterminado) | escritorio + micrófono | `Pista 1=Mezcla`, `Pista 2=Escritorio`, `Pista 3=Micrófono` |
| `--audio desktop` | solo escritorio | `Escritorio` |
| `--audio mic` | solo micrófono | `Micrófono` |
| `--audio none` | solo video | — |

Las grabaciones manuales se guardan como `rec-YYYY-MM-DD_HH-MM-SS.mkv` en `~/Videos`. Los clips del Replay Buffer se guardan como `Clip_YYYY-MM-DD_HH-MM-SS.mkv` en `~/Videos/Clips`. Se usa MKV porque admite varias pistas de audio de forma limpia y mantiene los nombres de las pistas para editarlas fácilmente en VLC, mpv y otros programas.

### Configuración

La configuración se almacena en `~/.config/omarchy-screenrecorder/config.sh` y se puede gestionar desde el widget de la barra:

```bash
CLIP_DURATION=30
CLIP_DIR="$HOME/Videos/Clips"
REC_FPS=60
REC_CRF=20
REC_PRESET="veryfast"
REC_AUDIO_MODE="both"
CLIP_HOTKEY="SUPER + F10"
```

Los dispositivos de audio se detectan automáticamente desde la sesión de PipeWire activa:

- El audio del escritorio usa el monitor del sink predeterminado o audífonos USB activos.
- El micrófono usa la fuente predeterminada, ignorando automáticamente salidas tipo monitor.

Puedes forzar endpoints concretos con variables de entorno:

```bash
export RECORD_DESK_SOURCE="alsa_output.pci-0000_00_1f.3.analog-stereo.monitor"
export RECORD_MIC_SOURCE="alsa_input.usb-Tu_Micro-00.mono-fallback"
```

Para ver los nombres disponibles:

```bash
pactl list short sinks
pactl list short sources
```

### Cómo funciona el audio

El audio y el video se capturan por separado. El escritorio y el micrófono se graban con `ffmpeg` o loopbacks de PipeWire, mientras que la imagen se registra con `wf-recorder`. Al detenerse o guardar un clip, todo se muxa en un único MKV. En el modo `both`, se generan 3 pistas: `Pista 1=Mezcla`, `Pista 2=Escritorio` y `Pista 3=Micrófono`.

### Solución de problemas

**El icono de grabación no aparece en la barra.**

Si no estaba al ejecutar el instalador, añádelo manualmente:

```bash
omarchy bar put "$(id -un).indicators" --section center --before omarchy.clock
```

Luego re-escanea los plugins: `omarchy-shell shell rescanPlugins`. El widget se recarga automáticamente al guardar.

**El menú sigue mostrando entradas de `gpu-screen-recorder`.**

El proxy solo tiene prioridad cuando `~/.config/omarchy/bin` está antes que `/usr/share/omarchy/bin` en tu `PATH`. Cierra sesión y vuelve a entrar para aplicar la override del entorno.

**No se graba nada o el archivo queda vacío.**

Revisa el registro del daemon:

```bash
$XDG_RUNTIME_DIR/record-screen-daemon.log
```

### Desinstalación

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -f ~/.local/bin/record-screen-clip ~/.local/bin/record-screen-clip-daemon ~/.local/bin/record-screen-config-helper
rm -rf ~/.config/omarchy/plugins/"$(id -un).indicators"
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

Elimina los atajos de `~/.config/hypr/bindings.lua` y reinicia la sesión.

### Licencia

MIT