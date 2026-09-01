# omarchy-screenrecorder

> Screen recording for Hyprland/Omarchy that **won't crash your AMD VCE GPU.**

Works where `gpu-screen-recorder` is unusable: on Polaris (RX 500-series) cards
it initializes the hardware encoder and the kernel ring buffer times out
(`ring vce0 timeout` → GPU reset → freeze). This project records with
**CPU-encoded h264 (libx264 via [wf-recorder](https://github.com/ammen99/wf-recorder))**
so the GPU encoder is never touched.

Built for and tested on Omarchy (Hyprland + Quickshell + Waybar-style bar).

---

## Features

- **Toggle recording** — one key to start/stop (`record-screen`).
- **Region picker across all monitors** — `--region` freezes the whole desktop
  (via `hyprpicker`) and lets you click any monitor or visible window to snap to
  it, or drag a free rectangle. Works across multiple monitors, unlike the
  built-in trigger (`--region` clips to the active workspace).
- **Multi-track audio** — desktop and microphone are captured as **separate
  named AAC tracks**, plus an optional mixed track, so you can mute/split either
  source in editing.
- **Bar indicator** — shows a recording icon and doubles as a start/stop toggle.
- **Menu integration** — Start/Stop entries under *Capture → Screenrecord*.
- Offscreen-safe: video uses `wf-recorder` with **no audio** (avoids the
  fragile PipeWire loopback/null-sink mixing that only picked up the mic).

## Installation

### Requirements

- `wf-recorder`, `ffmpeg`, `slurp`, `hyprpicker`, `jq`, `sed`
- Hyprland + the Omarchy shell/Quickshell and its notification daemon
  (`omarchy-notification-send`).

### Install

```bash
git clone https://github.com/<you>/omarchy-screenrecorder.git
cd omarchy-screenrecorder
./install.sh
```

Idempotent — safe to re-run. It installs:

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

Add to `~/.config/hypr/bindings.lua` (uses the absolute path so it works even
before the new PATH takes effect — the scripts are at `~/.local/bin`):

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

Outputs `rec-YYYY-MM-DD_HH-MM-SS.mkv` in `$XDG_VIDEOS_DIR` (`~/Videos`).
MKV is used because it carries multiple audio tracks cleanly (mp4 doesn't);
the tracks are named and appear in mpv/VLC/editors.

A notification confirms start immediately; if wf-recorder fails to launch, a
critical notification reports it ~3 s later.

## Configuration

Set your audio endpoints in `scripts/record-screen-daemon`:

```bash
DESK_SOURCE="alsa_output.usb-Your_Headset-00.analog-stereo.monitor"
MIC_SOURCE="alsa_input.usb-Your_Usb_Mic-00.mono-fallback"
```

Find the names with:

```bash
pactl list short sinks   # pick "*.monitor" of your default output
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

**Menu still shows gpu-screen-recorder entries.** The proxy only wins if
`~/.config/omarchy/bin` is ahead of `/usr/share/omarchy/bin` in `PATH` — apply
the `environment.d` override by logging out/in.

**Nothing recorded / zero-byte output.** Check `wf-recorder` and `ffmpeg` stderr:
`record-screen-daemon` writes to this project's `$XDG_RUNTIME_DIR/record-screen-daemon.log`.

## Uninstall

```bash
rm -f ~/.local/bin/record-screen ~/.local/bin/record-screen-daemon
rm -rf ~/.config/omarchy/plugins/<user>.indicators
rm -f ~/.config/omarchy/extensions/omarchy-menu.jsonc  # only the screenrecord keys
rm -f ~/.config/omarchy/bin/omarchy-capture-screenrecording
rm -f ~/.config/environment.d/record-screen-path.conf
```

Revert the two keybindings. Restart the session for the PATH change to release.

## See also

- [wf-recorder](https://github.com/ammen99/wf-recorder) — the recorder this
  wraps. `wf-recorder -g` provides the built-in geometry selector.

## License

MIT