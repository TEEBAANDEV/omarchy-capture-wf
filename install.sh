#!/bin/bash
# Install omarchy-screenrecorder.
#
# Installs everything needed by the wf-recorder screen recorder on this
# Hyprland/Omarchy system:
#   1. record-screen (toggle) + record-screen-daemon  -> ~/.local/bin
#   2. <user>.indicators bar plugin (indicator)       -> ~/.config/omarchy/plugins
#   3. omarchy-menu.jsonc extension (Start/Stop)      -> ~/.config/omarchy/extensions
#   4. omarchy-capture-screenrecording proxy          -> ~/.config/omarchy/bin
#   5. environment.d PATH override                    -> ~/.config/environment.d
#
# Bindings (SUPER+SHIFT+R / SUPER+SHIFT+ALT+R in ~/.config/hypr/bindings.lua)
# are NOT modified automatically -- add them yourself (see README).
#
# Requirements: wf-recorder, ffmpeg, slurp, hyprpicker, jq, sed, omarchy-shell.
# Safe to run repeatedly.

set -e

P="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UID_NAME="${USER:-$(id -un)}"
PLUGIN_ID="${UID_NAME}.indicators"

install() {
  local src="$1" dst="$2" mode="$3"
  mkdir -p "$(dirname "$dst")"
  install -D -m "$mode" "$src" "$dst"
  echo "installed: $dst"
}

# 1. Core scripts
install "$P/scripts/record-screen"        "$HOME/.local/bin/record-screen"        755
install "$P/scripts/record-screen-daemon" "$HOME/.local/bin/record-screen-daemon" 755

# 2. Bar indicator plugin (cloned from omarchy.indicators, edited to track wf-recorder)
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
mkdir -p "$PLUGIN_DIR/indicators"
sed "s|__USER__|$UID_NAME|" "$P/plugin/manifest.json" > "$PLUGIN_DIR/manifest.json"
chmod 644 "$PLUGIN_DIR/manifest.json"
install "$P/plugin/Indicators.qml" "$PLUGIN_DIR/Indicators.qml" 644
for qml in "$P/plugin/indicators/"*.qml; do
  install "$qml" "$PLUGIN_DIR/indicators/$(basename "$qml")" 644
done
echo "installed: plugin $PLUGIN_ID (hot-reloads on save; switch via omarchy bar layout if needed)"

# 3. Menu extension
install "$P/config/omarchy/extensions/omarchy-menu.jsonc" \
  "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc" 644

# 4. Proxy so omarchy-capture-screenrecording -> record-screen (no gpu-screen-recorder)
install "$P/config/omarchy/bin/omarchy-capture-screenrecording" \
  "$HOME/.config/omarchy/bin/omarchy-capture-screenrecording" 755

# 5. environment.d PATH (applies on next login)
install "$P/config/environment.d/record-screen-path.conf" \
  "$HOME/.config/environment.d/record-screen-path.conf" 644

echo
echo "Done. Notes:"
echo "  - environment.d PATH takes effect on your next login (Quickshell ignores"
echo "    the current session's PATH changes)."
echo "  - If the bar indicator does not reload, run: omarchy-shell shell rescanPlugins"
echo "  - Add keybindings manually (see README):"
echo "      SUPER+SHIFT+R       -> record-screen"
echo "      SUPER+SHIFT+ALT+R   -> record-screen --region"