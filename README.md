# omarchy-capture-wf (v1.1)

Screen recording and instant Replay Buffer / Clips mode for [Omarchy](https://github.com/omarchy/omarchy) on Wayland / Hyprland.

Replaces `gpu-screen-recorder` with a CPU-based `wf-recorder` + `ffmpeg` multi-track pipeline, avoiding driver crashes on AMD RX 580 GPUs while offering instant Replay Buffer clipping, custom region selection, and multi-track audio.

---

## 🌐 Language / Idioma
- [English](#-english)
- [Español](#-español)

---

## 🇬🇧 English

### ✨ Features (v1.1)

- 🎬 **Instant Replay Buffer / Clips Mode**: Continuously buffers video/audio in RAM. Press `SUPER + F10` to save the last N seconds (15s to 120s) instantly to `~/Videos/Clips/`.
- ✂️ **Screen & Region Buffer Modes**: Start the Replay Buffer for the full focused monitor or pick a custom screen region/window with `slurp`.
- 🎛️ **Multi-Track Audio**:
  - **Both (`both`)**: Produces 3 separate audio tracks (`Track 1=Mix`, `Track 2=Desktop`, `Track 3=Microphone`) for flexible post-editing.
  - **Desktop (`desktop`)**: 1 single audio track for desktop/system audio.
  - **Microphone (`mic`)**: 1 single audio track for mic input.
  - **None (`none`)**: Video only.
- 🎚️ **Interactive Bar Widget**: QML indicator panel with dark Omarchy UI (`qs.Ui`), live buffer controls, FPS selector (30/60), duration chips, and direct manual recording buttons.
- 🔒 **Settings Protection**: Settings options are automatically locked during active recording or buffer runs to prevent configuration desync.
- 🚀 **Zero Re-encoding**: Clips are concatenated instantly via FFmpeg stream copy (`-c copy`).

### 🎹 Default Hotkeys

| Shortcut | Action |
| --- | --- |
| `SUPER + F10` | 🎬 Save Instant Replay Clip (last N seconds) |
| `SUPER + SHIFT + F10` | 🔄 Toggle Replay Buffer Daemon |
| `SUPER + SHIFT + R` | 🔴 Toggle Full-Screen Manual Recording |
| `SUPER + SHIFT + ALT + R` | ✂️ Toggle Region Manual Recording |

### 📦 Installation

Clone and run `install.sh`:

```bash
git clone https://github.com/teebaan/omarchy-capture-wf.git
cd omarchy-capture-wf
./install.sh
```

Restart the shell to apply changes:

```bash
omarchy restart shell
```

### ⚙️ Configuration

Configuration is saved in `~/.config/omarchy-screenrecorder/config.sh` and can be adjusted dynamically via the bar widget or edited manually:

```bash
CLIP_DURATION=30
CLIP_DIR="$HOME/Videos/Clips"
REC_FPS=60
REC_CRF=20
REC_PRESET="veryfast"
REC_AUDIO_MODE="both"
CLIP_HOTKEY="SUPER + F10"
```

---

## 🇪🇸 Español

### ✨ Características (v1.1)

- 🎬 **Modo Clips / Replay Buffer Instantáneo**: Almacena continuamente video/audio en memoria RAM. Presiona `SUPER + F10` para guardar los últimos N segundos (15s a 120s) al instante en `~/Videos/Clips/`.
- ✂️ **Modos de Buffer por Pantalla o Región**: Inicia el Replay Buffer para la pantalla completa enfocada o selecciona una región/ventana con `slurp`.
- 🎛️ **Grabación de Audio Multipista**:
  - **Ambos (`both`)**: Genera 3 pistas de audio separadas (`Pista 1=Mezcla`, `Pista 2=Escritorio`, `Pista 3=Micrófono`) para edición profesional.
  - **Escritorio (`desktop`)**: 1 sola pista de audio para el sonido del sistema/juego.
  - **Micrófono (`mic`)**: 1 sola pista de audio para la voz del micrófono.
  - **Sin Audio (`none`)**: Video nativo sin sonido.
- 🎚️ **Widget Interactivo en la Barra**: Panel indicador QML con tema oscuro nativo de Omarchy (`qs.Ui`), controles en vivo para el buffer, selector de FPS (30/60), chips de duración y botones de grabación directa.
- 🔒 **Protección de Ajustes**: Las opciones de configuración se bloquean automáticamente durante grabaciones o ejecuciones del buffer activas.
- 🚀 **Sin Re-codificación**: Los clips se unen instantáneamente mediante copia de flujo FFmpeg (`-c copy`).

### 🎹 Atajos por Defecto

| Atajo | Acción |
| --- | --- |
| `SUPER + F10` | 🎬 Guardar Clip Instantáneo (últimos N segundos) |
| `SUPER + SHIFT + F10` | 🔄 Alternar Demonio de Replay Buffer |
| `SUPER + SHIFT + R` | 🔴 Alternar Grabación Manual (Pantalla Completa) |
| `SUPER + SHIFT + ALT + R` | ✂️ Alternar Grabación Manual (Región / Zona) |

### 📦 Instalación

Clona el repositorio y ejecuta `install.sh`:

```bash
git clone https://github.com/teebaan/omarchy-capture-wf.git
cd omarchy-capture-wf
./install.sh
```

Reinicia el shell de Omarchy para aplicar los cambios:

```bash
omarchy restart shell
```

### ⚙️ Configuración

La configuración se guarda en `~/.config/omarchy-screenrecorder/config.sh` y se puede ajustar dinámicamente desde el widget de la barra o editando el archivo manualmente:

```bash
CLIP_DURATION=30
CLIP_DIR="$HOME/Videos/Clips"
REC_FPS=60
REC_CRF=20
REC_PRESET="veryfast"
REC_AUDIO_MODE="both"
CLIP_HOTKEY="SUPER + F10"
```

---

## 📄 License / Licencia

MIT License.