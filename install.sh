#!/bin/bash
# Install omarchy-screenrecorder.
#
# Fully automatic, no manual steps required. Installs:
#   1. record-screen (toggle) + record-screen-daemon  -> ~/.local/bin
#   2. <user>.indicators bar plugin (indicator)       -> ~/.config/omarchy/plugins
#   3. omarchy-menu.jsonc extension (Start/Stop)      -> ~/.config/omarchy/extensions
#   4. omarchy-capture-screenrecording proxy          -> ~/.config/omarchy/bin
#   5. environment.d PATH override                    -> ~/.config/environment.d
#   6. Indicator widget added to the bar              -> omarchy bar put (via shell)
#   7. Start/Stop keybindings                         -> ~/.config/hypr/bindings.lua
#
# The default ALT+PRINT binding already routes through the proxy once the
# new PATH applies (next login). SUPER+SHIFT+R (toggle) and SUPER+SHIFT+ALT+R
# (region) are added if absent.
#
# Requirements: wf-recorder, ffmpeg, slurp, hyprpicker, jq, sed, omarchy-shell.
# Safe to run repeatedly.

set -e

P="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UID_NAME="${USER:-$(id -un)}"
PLUGIN_ID="${UID_NAME}.indicators"
BINDINGS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/bindings.lua"

install_file() {
  local src="$1" dst="$2" mode="$3"
  mkdir -p "$(dirname "$dst")"
  command install -D -m "$mode" "$src" "$dst"
  echo "installed: $dst"
}

add_binding_absent() {
  # Idempotent: only adds the key combination if a binding with the same keys
  # does not already exist. Never edits or duplicates an existing line.
  local script="$1" args="$2" desc="$3" keys="$4"
  if ! grep -qF "o.bind(\"$keys\"" "$BINDINGS_FILE" 2>/dev/null; then
    printf '%s\n' "o.bind(\"$keys\", \"$desc\", \"$script${args:+ $args}\")" >> "$BINDINGS_FILE"
    echo "binding added: $keys ($script${args:+ $args})"
  else
    echo "binding already present, skipping: $keys"
  fi
}

# 1. Core scripts
install_file "$P/scripts/record-screen"        "$HOME/.local/bin/record-screen"        755
install_file "$P/scripts/record-screen-daemon" "$HOME/.local/bin/record-screen-daemon" 755

# 2. Bar indicator plugin (cloned from omarchy.indicators, trimmed to wf-recorder)
PLUGIN_DIR="$HOME/.config/omarchy/plugins/$PLUGIN_ID"
mkdir -p "$PLUGIN_DIR/indicators"
sed "s|__USER__|$UID_NAME|" "$P/plugin/manifest.json" > "$PLUGIN_DIR/manifest.json"
chmod 644 "$PLUGIN_DIR/manifest.json"
install_file "$P/plugin/Indicators.qml" "$PLUGIN_DIR/Indicators.qml" 644
for qml in "$P/plugin/indicators/"*.qml; do
  install_file "$qml" "$PLUGIN_DIR/indicators/$(basename "$qml")" 644
done
echo "installed: plugin $PLUGIN_ID (hot-reloads on save)"

# 3. Menu extension
install_file "$P/config/omarchy/extensions/omarchy-menu.jsonc" \
  "$HOME/.config/omarchy/extensions/omarchy-menu.jsonc" 644

# 4. Proxy so omarchy-capture-screenrecording -> record-screen (no gpu-screen-recorder)
install_file "$P/config/omarchy/bin/omarchy-capture-screenrecording" \
  "$HOME/.config/omarchy/bin/omarchy-capture-screenrecording" 755

# 5. environment.d PATH (applies on next login)
install_file "$P/config/environment.d/record-screen-path.conf" \
  "$HOME/.config/environment.d/record-screen-path.conf" 644

# 6. Put the indicator widget on the bar (asks the running shell; harmless if
#    the shell is absent or the widget is already there).
if command -v omarchy >/dev/null 2>&1; then
  omarchy bar put "$PLUGIN_ID" --section center --before omarchy.clock \
    >/dev/null 2>&1 \
    && echo "bar widget added: $PLUGIN_ID" \
    || { command -v omarchy >/dev/null 2>&1 || true; echo "note: omarchy bar not available now; add <$PLUGIN_ID> to your bar later (see README)"; }
fi

# 7. Keybindings. Default ALT+PRINT already records via the proxy after login;
#    add the toggle/region shortcuts when missing.
if [[ -w $BINDINGS_FILE ]]; then
  add_binding_absent "$HOME/.local/bin/record-screen" "" "Screen recording toggle" "SUPER + SHIFT + R"
  add_binding_absent "$HOME/.local/bin/record-screen" "--region" "Screen recording region" "SUPER + SHIFT + ALT + R"
else
  echo "note: $BINDINGS_FILE not writable; add the two bindings yourself (see README)"
fi

echo
echo "Done. Notes:"
echo "  - environment.d PATH applies on your next login (Quickshell ignores"
echo "    mid-session PATH changes). Before that, standalone record-screen"
echo "    still works from a normal terminal."
echo "  - If the bar indicator did not appear, log out and in, then run:"
echo "      omarchy bar put $PLUGIN_ID --section center --before omarchy.clock"
echo "  - Validates with: hyprctl reload && hyprctl configerrors"