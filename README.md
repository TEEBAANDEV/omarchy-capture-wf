# omarchy-screenrecorder

[English](#english) · [Español](#espa%C3%B1ol)

A custom adaptation of a screen recorder for Hyprland/Omarchy, designed to avoid AMD VCE GPU crashes on affected cards while keeping the workflow simple and native to the desktop environment.

> Built for Omarchy (Hyprland + Quickshell) and optimized for hardware setups where `gpu-screen-recorder` fails because of VCE encoder instability.

---

## English

### Overview

This project exists because `gpu-screen-recorder` can become unusable on AMD Polaris cards such as the RX 500 series. In those systems, the hardware encoder can trigger kernel ring buffer timeouts (`ring vce0 timeout`), causing GPU resets and desktop freezes.

To avoid that, `omarchy-screenrecorder` records video with CPU-based H.264 using `wf-recorder` and `libx264`, so the GPU encoder is never used. Audio is captured separately and muxed into a single MKV file with multiple named tracks.

### Why this project is useful

- Avoids unstable AMD VCE encoder usage.
- Works well in Omarchy/Hyprland workflows.
- Includes a bar indicator and Capture menu integration.
- Supports region capture across monitors.
- Produces multi-track audio output for editing and post-production.

### Features

- Toggle recording with a single command: `record-screen`
- Region capture with `--region` using `hyprpicker`
- Multi-monitor support for region selection
- Audio capture from desktop and microphone as separate named tracks
- Optional unified `Mix` track
- Omarchy bar widget indicator for active recording state
- Menu entries under Capture → Screenrecord
- Recording output stored as MKV for clean multi-track handling

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
git clone https://github.com/TEEBAANDEV/omarchy-screenrecorder.git
cd omarchy-screenrecorder
chmod +x install.sh
./install.sh
```

If you are installing your own GitHub fork, replace `TEEBAANDEV` with your GitHub username, for example:

```bash
git clone https://github.com/<your-user>/omarchy-screenrecorder.git
```

The installer is idempotent and safe to re-run. It creates the following components:

| Component | Destination |
| --- | --- |
| `record-screen` / `record-screen-daemon` | `~/.local/bin` |
| Bar indicator plugin | `~/.config/omarchy/plugins/<user>.indicators/` |
| Menu override (Start/Stop) | `~/.config/omarchy/extensions/` |
| Proxy `omarchy-capture-screenrecording` | `~/.config/omarchy/bin/` |
| PATH override | `~/.config/environment.d/` |

> Note: the `environment.d` PATH override takes effect on the next login because the active Quickshell session does not reload `PATH` changes mid-session. If the bar indicator does not detect the proxy, log out and log back in.

### Keybindings

Add the following to `~/.config/hypr/bindings.lua` using absolute paths so they work before the updated PATH is active:

```lua
o.bind("SUPER + SHIFT + R", "Screen recording toggle", "~/.local/bin/record-screen")
o.bind("SUPER + SHIFT + ALT + R", "Screen recording region", "~/.local/bin/record-screen --region")
```

Then reload the config:

```bash
hyprctl reload
hyprctl configerrors
```

### Usage

```bash
record-screen                 # toggle recording of the focused monitor
record-screen --region        # choose a region, monitor, or window and record
record-screen --audio mic     # record only the microphone track (default: both)
```

| Flag | Value | Output tracks |
| --- | --- | --- |
| `--audio both` (default) | desktop + mic | `Desktop`, `Microphone`, `Mix` |
| `--audio desktop` | desktop only | `Desktop` |
| `--audio mic` | mic only | `Microphone` |
| `--audio none` | video only | — |

Files are saved as `rec-YYYY-MM-DD_HH-MM-SS.mkv` in `$XDG_VIDEOS_DIR` (typically `~/Videos`). MKV is used because it cleanly supports multiple audio tracks while keeping them named and easy to edit in tools such as VLC, mpv, and video editors.

A notification appears immediately when recording starts; if startup fails, a critical notification is sent a few seconds later.

### Configuration

Audio devices are auto-detected from the active PipeWire session:

- Desktop audio uses the default sink monitor output.
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

Look for the `.monitor` entry from your default output and the source name of your microphone.

### How audio is handled

Audio and video are captured separately. The desktop and mic inputs are captured directly with `ffmpeg`, while the video stream is recorded with `wf-recorder`. On stop, the streams are muxed into a single MKV. For `--audio both`, the `Mix` track is composed dynamically using an `asplit`/`amix` filter chain.

### Troubleshooting

**The recording icon does not appear in the bar.**

```bash
omarchy-shell shell rescanPlugins
```

Then add the `<user>.indicators` widget to the bar layout. It hot-reloads on save.

**The menu still shows `gpu-screen-recorder` entries.**

The proxy only takes precedence when `~/.config/omarchy/bin` is ahead of `/usr/share/omarchy/bin` in your `PATH`. Log out and log back in so the environment override is applied.

**Nothing is recorded or the output is zero bytes.**

Check the daemon logs:

```bash
$XDG_RUNTIME_DIR/record-screen-daemon.log
```

The script redirects `wf-recorder` and `ffmpeg` stderr there, which is the best place to diagnose startup problems.

### Uninstall

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -rf ~/.config/omarchy/plugins/<user>.indicators
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

Also remove the two custom keybindings and restart the session so the `PATH` override is cleared.

### License

MIT

---

## Español

### Visión general

Este proyecto es una adaptación personalizada para resolver un problema real: `gpu-screen-recorder` puede resultar inutilizable en tarjetas AMD Polaris, como la serie RX 500. En esos equipos, el encoder de hardware puede disparar timeouts del buffer del kernel (`ring vce0 timeout`), provocando reinicios de la GPU y congelaciones del sistema.

Para evitarlo, `omarchy-screenrecorder` graba video con H.264 basado en CPU usando `wf-recorder` y `libx264`, de modo que el encoder de la GPU nunca se utiliza. El audio se captura por separado y se mezcla en un único archivo MKV con varias pistas nombradas.

### Por qué este proyecto es útil

- Evita el uso del encoder AMD VCE inestable.
- Encaja bien con flujos de trabajo de Omarchy/Hyprland.
- Incluye un indicador en la barra y una integración con el menú de captura.
- Soporta grabación por región en varios monitores.
- Genera audio multipista para edición y postproducción.

### Características

- Grabación con un solo comando: `record-screen`
- Captura por región con `--region` usando `hyprpicker`
- Soporte para varios monitores al seleccionar la región
- Captura de audio del escritorio y del micrófono como pistas separadas
- Pista opcional de mezcla `Mix`
- Indicador de estado de grabación en la barra de Omarchy
- Entradas en el menú Captura → Screenrecord
- Salida en MKV para manejar varias pistas de forma limpia

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

Si tu repositorio está publicado en GitHub bajo tu usuario, clónalo así:

```bash
git clone https://github.com/TEEBAANDEV/omarchy-screenrecorder.git
cd omarchy-screenrecorder
chmod +x install.sh
./install.sh
```

Si usas un fork o un repositorio con otro nombre de usuario, solo cambia la parte del propietario en la URL:

```bash
git clone https://github.com/<tu-usuario>/omarchy-screenrecorder.git
```

El instalador es idempotente y se puede ejecutar varias veces sin problemas. Crea los siguientes componentes:

> Nota: el usuario de GitHub en la URL del clon no es lo mismo que el usuario del sistema Linux que usa el instalador. El nombre del plugin se genera a partir del usuario local, así que normalmente queda en `~/.config/omarchy/plugins/<usuario-linux>.indicators/`.

| Componente | Destino |
| --- | --- |
| `record-screen` / `record-screen-daemon` | `~/.local/bin` |
| Plugin del indicador de barra | `~/.config/omarchy/plugins/<usuario>.indicators/` |
| Override del menú (Iniciar/Detener) | `~/.config/omarchy/extensions/` |
| Proxy `omarchy-capture-screenrecording` | `~/.config/omarchy/bin/` |
| Override de PATH | `~/.config/environment.d/` |

> Nota: el override de `environment.d` se aplica en el próximo inicio de sesión porque el Quickshell activo no recarga cambios de `PATH` en mitad de sesión. Si el indicador no detecta el proxy, cierra sesión y vuelve a entrar.

### Atajos de teclado

Añade lo siguiente a `~/.config/hypr/bindings.lua` usando rutas absolutas para que funcione antes de que el nuevo `PATH` esté activo:

```lua
o.bind("SUPER + SHIFT + R", "Screen recording toggle", "~/.local/bin/record-screen")
o.bind("SUPER + SHIFT + ALT + R", "Screen recording region", "~/.local/bin/record-screen --region")
```

Luego recarga la configuración:

```bash
hyprctl reload
hyprctl configerrors
```

### Uso

```bash
record-screen                 # activa o pausa la grabación del monitor activo
record-screen --region        # elige una región, un monitor o una ventana y graba
record-screen --audio mic     # solo graba el micrófono (por defecto: both)
```

| Opción | Valor | Pistas generadas |
| --- | --- | --- |
| `--audio both` (predeterminado) | escritorio + micrófono | `Desktop`, `Microphone`, `Mix` |
| `--audio desktop` | solo escritorio | `Desktop` |
| `--audio mic` | solo micrófono | `Microphone` |
| `--audio none` | solo video | — |

Los archivos se guardan como `rec-YYYY-MM-DD_HH-MM-SS.mkv` en `$XDG_VIDEOS_DIR` (normalmente `~/Videos`). Se usa MKV porque admite varias pistas de audio de forma limpia y mantiene los nombres de las pistas para editarlas fácilmente en VLC, mpv y otros programas.

Cuando empieza la grabación aparece una notificación inmediata; si el arranque falla, se envía una notificación crítica unos segundos después.

### Configuración

Los dispositivos de audio se detectan automáticamente desde la sesión de PipeWire activa:

- El audio del escritorio usa el monitor del sink predeterminado.
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

Busca la entrada `.monitor` de tu salida predeterminada y el nombre del micrófono que quieras usar.

### Cómo funciona el audio

El audio y el video se capturan por separado. El escritorio y el micrófono se graban directamente con `ffmpeg`, mientras que la imagen se registra con `wf-recorder`. Al detenerse, todo se muxa en un único MKV. En el modo `--audio both`, la pista `Mix` se compone dinámicamente con un filtro `asplit`/`amix`.

### Solución de problemas

**El icono de grabación no aparece en la barra.**

```bash
omarchy-shell shell rescanPlugins
```

Luego añade el widget `<usuario>.indicators` al layout de la barra. Se recarga automáticamente al guardar.

**El menú sigue mostrando entradas de `gpu-screen-recorder`.**

El proxy solo tiene prioridad cuando `~/.config/omarchy/bin` está antes que `/usr/share/omarchy/bin` en tu `PATH`. Cierra sesión y vuelve a entrar para aplicar la override del entorno.

**No se graba nada o el archivo queda vacío.**

Revisa el registro del daemon:

```bash
$XDG_RUNTIME_DIR/record-screen-daemon.log
```

El script redirige el stderr de `wf-recorder` y `ffmpeg` allí, y suele ser el mejor punto para diagnosticar errores de inicio.

### Desinstalación

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -rf ~/.config/omarchy/plugins/<usuario>.indicators
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

También elimina los dos atajos personalizados y reinicia la sesión para liberar el cambio de `PATH`.

### Licencia

MIT