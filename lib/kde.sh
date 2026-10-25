#!/usr/bin/env bash

set -euo pipefail

# KDE apps rewrite their config files whole when saving, which would replace a stowed link,
# so their settings are written in place with kwriteconfig6, as defaults.sh does on macOS.

kde_setup() {
  log_step "Applying KDE settings"

  ### KEYBOARD ###
  # Held keys repeat (rather than offer accents), after 225 ms, 33 times a second: macOS's
  # InitialKeyRepeat 15 and KeyRepeat 2. Takes effect at the next login.
  kwriteconfig6 --file kcminputrc --group Keyboard --key KeyRepeat repeat
  kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatDelay 225
  kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatRate 33

  ### HOT CORNERS ###
  # The top-left corner opens the Overview by default; 9 is no screen edge.
  kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9
  dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure || true

  ### CLOCK ###
  # The panel clock in 24-hour time (2; 1 follows the locale), leaving US dates everywhere.
  # Through Plasma's scripting, since plasmashell rewrites its panel config while running.
  dbus-send --session --type=method_call --dest=org.kde.plasmashell /PlasmaShell \
    org.kde.PlasmaShell.evaluateScript string:'
      panels().forEach(function (panel) {
        panel.widgets("org.kde.plasma.digitalclock").forEach(function (clock) {
          clock.currentConfigGroup = ["Appearance"];
          clock.writeConfig("use24hFormat", 2);
        });
      });' >/dev/null || log_info "Plasma isn't running; the clock stays as it is"

  ### DOLPHIN ###
  # One view for every folder (Dolphin's default), and that view: Details, hidden files
  # shown, folders first. Version 4 is the format Dolphin writes, so it doesn't redo it.
  local view="$HOME/.local/share/dolphin/view_properties/global/.directory"
  mkdir -p "${view%/*}"
  kwriteconfig6 --file dolphinrc --group General --key GlobalViewProps true
  kwriteconfig6 --file "$view" --group Dolphin --key Version 4
  kwriteconfig6 --file "$view" --group Dolphin --key ViewMode 1
  kwriteconfig6 --file "$view" --group Dolphin --key SortFoldersFirst true
  kwriteconfig6 --file "$view" --group Settings --key HiddenFilesShown true
  kwriteconfig6 --file dolphinrc --group General --key ShowFullPathInTitlebar true

  ### SCREENSHOTS ###
  # Spectacle saves PNGs to ~/Documents/Screenshots, named like macOS's "shot <date> at <time>".
  mkdir -p "$HOME/Documents/Screenshots"
  kwriteconfig6 --file spectaclerc --group ImageSave --key imageSaveLocation "file://$HOME/Documents/Screenshots/"
  kwriteconfig6 --file spectaclerc --group ImageSave --key preferredImageFormat PNG
  kwriteconfig6 --file spectaclerc --group ImageSave --key imageFilenameTemplate "shot <yyyy>-<MM>-<dd> at <HH>.<mm>.<ss>"

  ### DEFAULT TERMINAL ###
  # Ghostty for "Open Terminal Here" and anything else KDE opens a terminal for.
  kwriteconfig6 --file kdeglobals --group General --key TerminalApplication ghostty
  kwriteconfig6 --file kdeglobals --group General --key TerminalService com.mitchellh.ghostty.desktop

  ### OKULAR ###
  # Shift-click in a PDF built with synctex jumps to that line in Zed (inverse search;
  # forward search is tex-forward-search). Zed by full path, since Okular started from the
  # menu doesn't have ~/.local/bin on PATH.
  kwriteconfig6 --file okularpartrc --group "Core General" --key ExternalEditor Custom
  kwriteconfig6 --file okularpartrc --group "Core General" --key ExternalEditorCommand "$HOME/.local/bin/zed %f:%l"
}
