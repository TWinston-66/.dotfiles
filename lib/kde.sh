#!/usr/bin/env bash

set -euo pipefail

# KDE apps rewrite their config files whole when saving, which would replace a stowed link,
# so their settings are written in place with kwriteconfig6, as defaults.sh does on macOS.

kde_setup() {
  log_step "Applying KDE settings"

  ### THEME ###
  # Gruvbox Material, from the scheme the fedora package stows into color-schemes, with
  # its blue as the accent (in place of any custom or wallpaper accent). GTK apps follow it
  # through Breeze-GTK. Applying a scheme copies its colours into kdeglobals, so it's a
  # command rather than a stowed kdeglobals.
  local line
  plasma-apply-colorscheme GruvboxMaterial 2>&1 | while IFS= read -r line; do
    if [ -n "$line" ]; then log_info "$line"; fi
  done
  plasma-apply-colorscheme --accent-color '#7daea3' 2>&1 | while IFS= read -r line; do
    if [ -n "$line" ]; then log_info "$line"; fi
  done
  # The Gruvbox Plus icons upstream.sh installs, through the helper System Settings uses,
  # which also tells running apps. Without it, they take the icons at the next login.
  if [ -x /usr/libexec/plasma-changeicons ]; then
    /usr/libexec/plasma-changeicons Gruvbox-Plus-Dark 2>&1 | while IFS= read -r line; do
      if [ -n "$line" ]; then log_info "$line"; fi
    done
  else
    kwriteconfig6 --file kdeglobals --group Icons --key Theme Gruvbox-Plus-Dark
    log_info "Gruvbox Plus icons set; they take effect at the next login"
  fi

  ### KEYBOARD ###
  # Held keys repeat (rather than offer accents), after 225 ms, 33 times a second: macOS's
  # InitialKeyRepeat 15 and KeyRepeat 2. Takes effect at the next login.
  kwriteconfig6 --file kcminputrc --group Keyboard --key KeyRepeat repeat
  kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatDelay 225
  kwriteconfig6 --file kcminputrc --group Keyboard --key RepeatRate 33

  ### TRACKPAD ###
  # Natural scrolling, as on the Mac. KWin keeps it per device, in kcminputrc groups named
  # by vendor and product IDs, so it's set on each touchpad through KWin's D-Bus API, and
  # KWin saves it there. A touchpad first connected later starts with KDE's default.
  local devices device touchpads=0
  if devices="$(busctl --user -j get-property org.kde.KWin /org/kde/KWin/InputDevice \
    org.kde.KWin.InputDeviceManager devicesSysNames 2>/dev/null)"; then
    for device in $(jq -r '.data[]' <<<"$devices"); do
      if [ "$(busctl --user -j get-property org.kde.KWin "/org/kde/KWin/InputDevice/$device" \
        org.kde.KWin.InputDevice touchpad | jq -r .data)" = true ]; then
        busctl --user set-property org.kde.KWin "/org/kde/KWin/InputDevice/$device" \
          org.kde.KWin.InputDevice naturalScroll b true
        log_info "Natural scrolling on for $(busctl --user -j get-property org.kde.KWin \
          "/org/kde/KWin/InputDevice/$device" org.kde.KWin.InputDevice name | jq -r .data)"
        touchpads=$((touchpads + 1))
      fi
    done
    if [ "$touchpads" -eq 0 ]; then log_info "No touchpad found"; fi
  else
    log_info "KWin isn't running; scrolling stays as it is"
  fi

  ### HOT CORNERS ###
  # The top-left corner opens the Overview by default; 9 is no screen edge.
  kwriteconfig6 --file kwinrc --group Effect-overview --key BorderActivate 9
  dbus-send --session --type=method_call --dest=org.kde.KWin /KWin org.kde.KWin.reconfigure || true

  ### CLOCK ###
  # The panel clock in 24-hour time (2; 1 follows the locale), leaving US dates everywhere.
  # Through Plasma's scripting, since plasmashell rewrites its panel config while running.
  # It reports each clock it set, or that there was none.
  # An en_DK time format, from before, would keep dates ISO, so it goes.
  kwriteconfig6 --file plasma-localerc --group Formats --key LC_TIME --delete
  local clock_result
  if clock_result="$(dbus-send --session --print-reply --type=method_call --dest=org.kde.plasmashell \
    /PlasmaShell org.kde.PlasmaShell.evaluateScript string:'
      var found = 0;
      panels().forEach(function (panel) {
        panel.widgets("org.kde.plasma.digitalclock").forEach(function (clock) {
          clock.currentConfigGroup = ["Appearance"];
          clock.writeConfig("use24hFormat", 2);
          clock.reloadConfig();
          found++;
          print("Panel clock " + clock.id + " set to 24-hour (now " + clock.readConfig("use24hFormat", "unset") + ")");
        });
      });
      if (!found) print("No digital clock found on a panel");')"; then
    # The reply is a header line, then the printed lines as one string: string "...".
    tail -n +2 <<<"$clock_result" | sed -e '1s/^ *string "//' -e '$s/"$//' | while IFS= read -r line; do
      if [ -n "$line" ]; then log_info "$line"; fi
    done
  else
    log_info "Plasma isn't running; the clock stays as it is"
  fi

  ### BATTERY ###
  # The battery shows its percentage in the panel. It lives in the system tray, which keeps
  # its applets in its own config group, out of reach of Plasma's scripting, so the setting
  # is written into the panel config directly. plasmashell rewrites that file while running,
  # so it's stopped around the write, and only when the setting is missing.
  local appletsrc="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" header group stopped=0
  local -a headers=() args=()
  mapfile -t headers < <(awk '/^\[/ { h = $0 } $0 == "plugin=org.kde.plasma.battery" { print h }' \
    "$appletsrc" 2>/dev/null)
  for header in "${headers[@]}"; do
    # [Containments][2][Applets][7][Applets][15] is one --group per name.
    header="${header#[}"
    header="${header%]}"
    args=()
    while IFS= read -r group; do args+=(--group "$group"); done <<<"${header//\]\[/$'\n'}"
    args+=(--group Configuration --group General --key showPercentage)
    if [ "$(kreadconfig6 --file "$appletsrc" "${args[@]}")" = true ]; then
      log_info "Battery already shows its percentage"
      continue
    fi
    if [ "$stopped" -eq 0 ] && systemctl --user is-active --quiet plasma-plasmashell.service; then
      systemctl --user stop plasma-plasmashell.service
      stopped=1
    fi
    kwriteconfig6 --file "$appletsrc" "${args[@]}" true
    log_info "Battery shows its percentage"
  done
  if [ "$stopped" -eq 1 ]; then systemctl --user start plasma-plasmashell.service; fi
  if [ "${#headers[@]}" -eq 0 ]; then log_info "No battery found in a system tray"; fi

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
