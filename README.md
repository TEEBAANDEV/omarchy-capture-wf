# omarchy-capture-wf (v1.1)

Screen recording and Medal-style instant replay buffer clipping for [Omarchy](https://github.com/omarchy/omarchy) on Wayland / Hyprland.

Replaces `gpu-screen-recorder` with a CPU-based `wf-recorder` + `ffmpeg` multi-track pipeline, avoiding driver crashes on AMD RX 580 GPUs while offering instant buffer clipping, custom region selection, and multi-track audio.

---

## ✨ Features (v1.1)

- 🎬 **Medal-Style Instant Replay Buffer**: Continuously buffers video/audio in RAM. Press `SUPER + F10` to save the last N seconds (15s to 120s) instantly to `~/Videos/Clips/`.
- ✂️ **Screen & Region Buffer Modes**: Start the Replay Buffer for the full focused monitor or pick a custom screen region/window with `slurp`.
- 🎛️ **Multi-Track Audio**:
  - **Both (`both`)**: Produces 3 separate audio tracks (`Track 1=Mix`, `Track 2=Desktop`, `Track 3=Microphone`) for flexible post-editing.
  - **Desktop (`desktop`)**: 1 single audio track for desktop/system audio.
  - **Microphone (`mic`)**: 1 single audio track for mic input.
  - **None (`none`)**: Video only.
- 🎚️ **Interactive Bar Widget**: QML indicator panel with dark Omarchy UI (`qs.Ui`), live buffer controls, FPS selector (30/60), duration chips, and direct manual recording buttons.
- 🔒 **Settings Protection**: Settings options are automatically locked during active recording or buffer runs to prevent configuration desync.
- 🚀 **Zero Re-encoding**: Clips are concatenated instantly via FFmpeg stream copy (`-c copy`).

---

## 🎹 Default Hotkeys

| Shortcut | Action |
| --- | --- |
| `SUPER + F10` | 🎬 Save Instant Replay Clip (last N seconds) |
| `SUPER + SHIFT + F10` | 🔄 Toggle Replay Buffer Daemon |
| `SUPER + SHIFT + R` | 🔴 Toggle Full-Screen Manual Recording |
| `SUPER + SHIFT + ALT + R` | ✂️ Toggle Region Manual Recording |

---

## 📦 Installation

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

---

## ⚙️ Configuration

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

## 📄 License

MIT License.