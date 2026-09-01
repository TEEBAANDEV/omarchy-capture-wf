import QtQuick
import QtQuick.Layouts
import qs.Commons
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Ui

BarIndicator {
  id: root

  property bool recording: false
  property bool bufferRunning: false
  property string clipDuration: "30"
  property string recFps: "60"
  property string recAudioMode: "both"
  property string clipHotkey: "SUPER + F10"
  property bool cardOpen: false

  active: recording || bufferRunning
  activeText: recording ? "🔴 REC" : (bufferRunning ? "󰑋" : "󰻂")
  inactiveText: "󰻂"
  activeTooltipText: recording ? "🔴 GRABANDO PANTALLA... (clic para detener)" : (bufferRunning ? "Replay Buffer activo (" + clipDuration + "s - " + clipHotkey + ")" : "Replay Buffer desactivado")
  inactiveTooltipText: "Grabación y Clips (Medal)"

  function refreshState() {
    if (statusProc.running) return
    statusProc.running = true
  }

  function setConfig(key, val) {
    if (root.recording || root.bufferRunning) return
    setProc.command = [Quickshell.env("HOME") + "/.local/bin/record-screen-config-helper", "set", key, String(val)]
    setProc.running = true
  }

  onBarChanged: refreshState()
  Component.onCompleted: refreshState()

  Timer {
    id: pollTimer
    interval: 1500
    running: root.cardOpen || root.bufferRunning || root.recording
    repeat: true
    onTriggered: root.refreshState()
  }

  Timer {
    id: delayRefreshTimer
    interval: 400
    repeat: false
    onTriggered: root.refreshState()
  }

  Connections {
    target: root.indicatorHost
    ignoreUnknownSignals: true
    function onRefreshRequested() { root.refreshState() }
  }

  Process {
    id: statusProc
    command: [Quickshell.env("HOME") + "/.local/bin/record-screen-config-helper", "json"]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var data = JSON.parse(text)
          root.clipDuration = String(data.clipDuration || "30")
          root.recFps = String(data.recFps || "60")
          root.recAudioMode = String(data.recAudioMode || "both")
          root.clipHotkey = String(data.clipHotkey || "SUPER + F10")
          root.bufferRunning = data.bufferRunning === true
          root.recording = data.recording === true
        } catch (err) {}
      }
    }
  }

  Process {
    id: setProc
    onExited: function() {
      root.refreshState()
    }
  }

  PanelWindow {
    id: cardWindow
    visible: root.cardOpen
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    WlrLayershell.namespace: "omarchy-screenrecording-panel"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    MouseArea {
      anchors.fill: parent
      focus: true
      Keys.onEscapePressed: root.cardOpen = false
      onClicked: root.cardOpen = false

      Rectangle {
        id: card
        x: Math.max(20, Math.min(Screen.width - width - 20, root.mapToGlobal(root.width / 2, root.height).x - width / 2))
        y: root.mapToGlobal(0, root.height).y + Style.space(6)
        width: 410
        height: col.implicitHeight + Style.space(24)
        color: Color.background
        border.color: root.recording ? Color.urgent : Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.4)
        border.width: Style.normalBorderWidth
        radius: Style.cornerRadius

        MouseArea {
          anchors.fill: parent
          onClicked: {}
        }

        Column {
          id: col
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.margins: Style.space(14)
          spacing: Style.space(12)

          // Header
          Row {
            width: parent.width
            spacing: Style.space(8)

            Text {
              text: root.recording ? "🔴 GRABANDO PANTALLA" : "󰻂 Grabación & Clips"
              font.family: Style.font.family
              font.pixelSize: Style.font.title
              font.bold: true
              color: root.recording ? Color.urgent : Color.foreground
              anchors.verticalCenter: parent.verticalCenter
            }
          }

          PanelSeparator { width: parent.width }

          // Banner de Estado Si está grabando
          Rectangle {
            visible: root.recording
            width: parent.width
            height: recBannerCol.implicitHeight + Style.space(14)
            color: Qt.rgba(Color.urgent.r, Color.urgent.g, Color.urgent.b, 0.15)
            border.color: Color.urgent
            border.width: 1
            radius: Style.cornerRadius / 2

            Column {
              id: recBannerCol
              anchors.fill: parent
              anchors.margins: Style.space(10)
              spacing: Style.space(6)

              Text {
                text: "🔴 Grabación en curso..."
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                color: Color.urgent
              }

              Button {
                width: parent.width
                text: "⏹ DETENER Y GUARDAR GRABACIÓN"
                onClicked: {
                  if (root.bar) root.bar.run("record-screen")
                  root.cardOpen = false
                  delayRefreshTimer.restart()
                }
              }
            }
          }

          // --- SECCIÓN REPLAY BUFFER (MEDAL) ---
          Rectangle {
            width: parent.width
            height: bufferCol.implicitHeight + Style.space(16)
            color: root.bufferRunning ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.12) : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.05)
            border.color: root.bufferRunning ? Color.accent : Qt.rgba(Color.foreground.r, Color.foreground.g, Color.foreground.b, 0.2)
            border.width: 1
            radius: Style.cornerRadius / 2

            Column {
              id: bufferCol
              anchors.fill: parent
              anchors.margins: Style.space(10)
              spacing: Style.space(8)

              Text {
                text: root.bufferRunning ? "🟢 Replay Buffer: ACTIVADO" : "⚪ Replay Buffer: DESACTIVADO"
                font.family: Style.font.family
                font.pixelSize: Style.font.body
                font.bold: true
                color: root.bufferRunning ? Color.accent : Color.foreground
              }

              RowLayout {
                width: parent.width
                spacing: Style.space(6)

                Button {
                  visible: !root.bufferRunning
                  Layout.fillWidth: true
                  text: "🖥️ Activar (Pantalla)"
                  onClicked: {
                    if (root.bar) root.bar.run("record-screen-clip-daemon start")
                    delayRefreshTimer.restart()
                  }
                }

                Button {
                  visible: !root.bufferRunning
                  Layout.fillWidth: true
                  text: "✂️ Activar (Zona / Región)"
                  onClicked: {
                    if (root.bar) root.bar.run("record-screen-clip-daemon --region")
                    root.cardOpen = false
                    delayRefreshTimer.restart()
                  }
                }

                Button {
                  visible: root.bufferRunning
                  Layout.fillWidth: true
                  text: "⏹ Desactivar Buffer"
                  onClicked: {
                    if (root.bar) root.bar.run("record-screen-clip-daemon stop")
                    delayRefreshTimer.restart()
                  }
                }
              }

              Text {
                text: root.bufferRunning ? "✓ Guardando continuamente los últimos " + root.clipDuration + "s en RAM. Presiona " + root.clipHotkey + " para guardar clip." : "ℹ️ Selecciona pantalla o región para iniciar el buffer de clips."
                font.family: Style.font.family
                font.pixelSize: Style.font.caption
                color: Color.foreground
                wrapMode: Text.Wrap
                width: parent.width
              }

              // Botón Guardar Clip Separado
              Button {
                width: parent.width
                text: "🎬 Guardar Clip (" + root.clipDuration + "s) [" + root.clipHotkey + "]"
                enabled: root.bufferRunning
                onClicked: {
                  if (root.bar) root.bar.run("record-screen-clip")
                  root.cardOpen = false
                }
              }
            }
          }

          // Aviso de Ajustes Bloqueados
          Text {
            visible: root.recording || root.bufferRunning
            text: "🔒 Ajustes bloqueados mientras la grabación o el buffer estén activos."
            font.family: Style.font.family
            font.pixelSize: Style.font.caption
            font.bold: true
            color: Color.accent
            wrapMode: Text.Wrap
            width: parent.width
          }

          // SECCIÓN DE CONFIGURACIÓN (BLOQUEADA SI HAY ACTIVIDAD)
          Column {
            width: parent.width
            spacing: Style.space(10)
            enabled: !root.recording && !root.bufferRunning
            opacity: (root.recording || root.bufferRunning) ? 0.45 : 1.0

            // Duración del Clip Selector
            Column {
              width: parent.width
              spacing: Style.space(6)

              Text {
                text: "⏱️ Duración del Clip (Replay Buffer):"
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                color: Color.foreground
              }

              ButtonGroup {
                width: parent.width
                value: root.clipDuration + "s"
                options: [
                  { value: "15s", label: "15s" },
                  { value: "30s", label: "30s" },
                  { value: "60s", label: "60s" },
                  { value: "90s", label: "90s" },
                  { value: "120s", label: "120s" }
                ]
                onChanged: function(val) {
                  var clean = val.replace("s", "")
                  root.setConfig("CLIP_DURATION", clean)
                }
              }
            }

            // Captura de Audio Selector
            Column {
              width: parent.width
              spacing: Style.space(6)

              Text {
                text: "🎙️ Captura de Audio:"
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                color: Color.foreground
              }

              ButtonGroup {
                width: parent.width
                value: root.recAudioMode
                options: [
                  { value: "both", label: "Ambos" },
                  { value: "desktop", label: "Escritorio" },
                  { value: "mic", label: "Mic" },
                  { value: "none", label: "Sin Audio" }
                ]
                onChanged: function(val) {
                  root.setConfig("REC_AUDIO_MODE", val)
                }
              }
            }

            // FPS Selector
            Column {
              width: parent.width
              spacing: Style.space(6)

              Text {
                text: "📺 FPS de Grabación:"
                font.family: Style.font.family
                font.pixelSize: Style.font.bodySmall
                font.bold: true
                color: Color.foreground
              }

              ButtonGroup {
                width: parent.width
                value: root.recFps + " FPS"
                options: [
                  { value: "60 FPS", label: "60 FPS" },
                  { value: "30 FPS", label: "30 FPS" }
                ]
                onChanged: function(val) {
                  var clean = val.replace(" FPS", "")
                  root.setConfig("REC_FPS", clean)
                }
              }
            }
          }

          PanelSeparator { width: parent.width }

          // --- SECCIÓN GRABACIÓN MANUAL DIRECTA ---
          Text {
            visible: !root.recording
            text: "🔴 Grabación Manual Directa:"
            font.family: Style.font.family
            font.pixelSize: Style.font.bodySmall
            font.bold: true
            color: Color.foreground
          }

          RowLayout {
            visible: !root.recording
            width: parent.width
            spacing: Style.space(8)

            Button {
              Layout.fillWidth: true
              text: "🔴 Grabar Pantalla"
              onClicked: {
                if (root.bar) root.bar.run("record-screen")
                root.cardOpen = false
                delayRefreshTimer.restart()
              }
            }

            Button {
              Layout.fillWidth: true
              text: "✂️ Grabar Región / Zona"
              onClicked: {
                if (root.bar) root.bar.run("record-screen --region")
                root.cardOpen = false
                delayRefreshTimer.restart()
              }
            }
          }

          // Secondary Action Buttons
          RowLayout {
            width: parent.width
            spacing: Style.space(8)

            Button {
              Layout.fillWidth: true
              text: "⚙️ Config.sh"
              onClicked: {
                if (root.bar) root.bar.run("xdg-open '" + Quickshell.env("HOME") + "/.config/omarchy-screenrecorder/config.sh'")
                root.cardOpen = false
              }
            }

            Button {
              Layout.fillWidth: true
              text: "Cerrar"
              onClicked: root.cardOpen = false
            }
          }
        }
      }
    }
  }

  onPressed: function() {
    root.refreshState()
    root.cardOpen = !root.cardOpen
  }
}
