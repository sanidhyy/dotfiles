import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Commons as Commons

Item {
  id: root

  property string backgroundPath: ""
  property string videoPosterPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool fingerprintUnavailable: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false
  property bool displaysBlank: false
  property string kernel: ""
  property string hostName: Quickshell.env("HOSTNAME") || Quickshell.env("HOST") || "omarchy"

  readonly property string userName: Quickshell.env("USER") || Quickshell.env("LOGNAME") || "user"
  readonly property real u: Math.min(width, height) / 100
  readonly property int fs: Math.round(root.u * 2.1)
  readonly property int hintFontSize: Math.round(root.u * 1.25)
  readonly property color ink: Commons.Color.foreground
  readonly property color dim: Util.alpha(Commons.Color.foreground, 0.5)
  readonly property bool errorState: failureMessage.length > 0
  readonly property var lockHints: [
    { chord: "Super+Esc", label: "Display off" },
    { chord: "Super+R", label: "Reboot" },
    { chord: "Super+S", label: "Shutdown" }
  ]

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  // Cache-busts a local image by appending `?v=`. Unused by this TTY view,
  // but kept so the service contract for backgrounds stays intact.
  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    if (inputEnabled) passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  // Waking a DPMS-blanked display can stall the compositor for seconds while
  // the monitor modesets, so the wake key's release arrives late and client-side
  // key repeat floods the field with that character. A held key has no business
  // typing a password; only holding Backspace/Delete to clear stays useful.
  function dropsAutoRepeat(key) {
    return key !== Qt.Key_Backspace && key !== Qt.Key_Delete
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  // The field loses focus while a password is checked (it is disabled then),
  // and forcing focus onto it would not stick until the check ends.
  function restorePasswordFocus() {
    if (inputEnabled && passwordInput.enabled && !passwordInput.activeFocus) forcePasswordFocus()
  }

  // A VT switch, which the NVIDIA driver forces around every suspend, takes the
  // keyboard away and Qt drops the field's focus with it. Nothing gives it back
  // when the keyboard returns, so typing went nowhere until the field was clicked.
  Window.onActiveFocusItemChanged: Qt.callLater(restorePasswordFocus)

  onPasswordTextChanged: syncPasswordText()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  onDisplaysBlankChanged: {
    if (!displaysBlank) Qt.callLater(restorePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  FileView {
    path: "/etc/hostname"
    printErrors: false
    onLoaded: {
      var name = String(text() || "").trim()
      if (name.length > 0) root.hostName = name
    }
  }

  FileView {
    path: "/proc/sys/kernel/osrelease"
    printErrors: false
    onLoaded: root.kernel = String(text() || "").trim()
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }

  component Line: Text {
    font.family: Style.font.family
    font.pixelSize: root.fs
    color: root.ink
    textFormat: Text.PlainText
    lineHeight: 1.3
  }

  Rectangle {
    anchors.fill: parent
    color: Commons.Color.background

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.BlankCursor
      onClicked: {
        if (!root.displaysBlank) root.restorePasswordFocus()
      }
    }

    Column {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.margins: Math.round(root.u * 5)
      spacing: 0

      Line { text: "Omarchy Linux " + root.kernel + " (tty1)" }
      Line { text: Qt.formatDateTime(clock.date, "ddd MMM d HH:mm:ss yyyy") }
      Line { text: " " }

      // Every wrong attempt leaves its trace, up to three, then the prompt
      // comes back.
      Repeater {
        model: Math.min(root.failedAttempts, 3)
        delegate: Column {
          Line { text: root.hostName + " login: " + root.userName }
          Line { text: "Password: " }
          Line { text: " " }
          Line { text: "Login incorrect"; color: Commons.Color.lock.textError }
          Line { text: " " }
        }
      }

      Line { text: root.hostName + " login: " + root.userName }
      Row {
        Line { text: "Password: " }
        Line { text: "●".repeat(root.passwordText.length) }
      }
    }

    Row {
      anchors.left: parent.left
      anchors.bottom: parent.bottom
      anchors.leftMargin: Math.round(root.u * 5)
      anchors.bottomMargin: Math.round(root.u * 5)
      spacing: Math.round(root.hintFontSize * 2)

      Repeater {
        model: root.lockHints

        Row {
          spacing: Math.round(root.hintFontSize * 0.6)

          Text {
            text: `[${modelData.chord}]`
            color: root.ink
            font.family: Style.font.family
            font.pixelSize: root.hintFontSize
            verticalAlignment: Text.AlignVCenter
          }

          Text {
            text: modelData.label
            color: root.dim
            font.family: Style.font.family
            font.pixelSize: root.hintFontSize
            verticalAlignment: Text.AlignVCenter
          }
        }
      }
    }

    TextInput {
      id: passwordInput
      x: Math.round(root.u * 5)
      y: Math.round(root.u * 5)
      width: Math.round(root.u * 40)
      height: Math.round(root.u * 3)
      opacity: 0
      activeFocusOnPress: true
      clip: true
      enabled: root.inputEnabled && !root.authenticatingPassword && !root.displaysBlank
      readOnly: root.authenticatingPassword || root.displaysBlank
      echoMode: TextInput.Password
      passwordCharacter: "\u25CF"
      passwordMaskDelay: 0
      color: Commons.Color.lock.text
      selectionColor: Commons.Color.lock.selection
      selectedTextColor: Commons.Color.lock.text
      font.family: Style.font.family
      font.pixelSize: root.fs
      cursorVisible: false
      cursorDelegate: Item {}

      onActiveFocusChanged: {
        Qt.callLater(root.restorePasswordFocus)
      }

      onTextChanged: {
        if (!root.syncingPasswordText) root.passwordTextEdited(text)
        if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
      }

      onAccepted: {
        var submitted = root.passwordText
        root.passwordTextEdited("")
        if (submitted.length > 0) root.submitPassword(submitted)
      }

      Keys.onPressed: function(event) {
        root.wakeRequested()
        if (event.isAutoRepeat && root.dropsAutoRepeat(event.key)) {
          event.accepted = true
          return
        }
        if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
          root.passwordTextEdited("")
          event.accepted = true
        }
      }
    }
  }
}
