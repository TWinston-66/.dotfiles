#!/usr/bin/env bash

set -euo pipefail

osascript -e 'tell application "System Settings" to quit' >/dev/null 2>&1 || true

UNIVERSALACCESS_WRITABLE=0
if defaults write com.apple.universalaccess _dotfiles_probe -bool true 2>/dev/null; then
  UNIVERSALACCESS_WRITABLE=1
  defaults delete com.apple.universalaccess _dotfiles_probe 2>/dev/null || true
else
  echo "WARNING: com.apple.universalaccess is not writable — Accessibility settings" >&2
  echo "         will be skipped. Grant Full Disk Access to this terminal in" >&2
  echo "         System Settings > Privacy & Security > Full Disk Access, then re-run." >&2
fi

sudo nvram SystemAudioVolume=" " # Disable boot sound

### APPEARANCE ###
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to true'

#### NSGlobal ###
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2 # fast repeat
defaults write NSGlobalDomain InitialKeyRepeat -int 15 # slow delay
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3 # Tab through all controls

defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2 # medium sidebar icons
defaults write NSGlobalDomain AppleWindowTabbingMode -string "always" # tabs, not windows
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Strip window animation latency
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
defaults write NSGlobalDomain NSUseAnimatedFocusRing -bool false
defaults write NSGlobalDomain NSScrollAnimationEnabled -bool false

### TRACKPAD / MOUSE ###
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true # natural scrolling

# Tap to click (built-in + bluetooth trackpad, and login window)
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Disable force click / haptic look-up
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool false

# Tracking and scroll speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5
defaults write NSGlobalDomain com.apple.mouse.scaling -float 2.5
defaults write NSGlobalDomain com.apple.scrollwheel.scaling -float 0.5

# Two-finger secondary click, corner click off (both trackpad domains)
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadCornerSecondaryClick -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 0

# Three-finger swipe is taken by drag, so Spaces move to four fingers
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2

# Ctrl+scroll to zoom the screen (262144 = Control)
if [ "$UNIVERSALACCESS_WRITABLE" -eq 1 ]; then
  defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
  defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
  defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true
fi

### WINDOW MANAGEMENT ###
# Native edge-drag tiling off — it fights Rectangle for the same gestures
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Don't scatter windows when clicking the wallpaper
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# Stage Manager off
defaults write com.apple.WindowManager GloballyEnabled -bool false
defaults write com.apple.WindowManager AutoHide -bool false

# Nothing on the desktop, and no desktop at all
defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.finder CreateDesktop -bool false

### MISSION CONTROL ###
defaults write com.apple.dock expose-group-apps -bool false # flat grid, not per-app stacks
defaults write com.apple.dock mru-spaces -bool false # don't reorder Spaces
defaults write com.apple.dock appswitcher-all-displays -bool true

### SAVE/PRINT ###
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

### FINDER ###
defaults write com.apple.finder AppleShowAllFiles -bool false # dotfiles stay hidden in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true # Show extensions
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # list view default
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # search current dir
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true # show posix path
defaults write com.apple.finder FXRemoveOldTrashItems -bool true # auto-empty after 30 days

# New windows open to Home
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME/"

# Don't scatter .DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Expand File Info panes by default
defaults write com.apple.finder FXInfoPanesExpanded -dict General -bool true OpenWith -bool true Privileges -bool true

# Spring-loading, no delay
defaults write NSGlobalDomain com.apple.springing.enabled -bool true
defaults write NSGlobalDomain com.apple.springing.delay -float 0

# AirDrop over ethernet / thunderbolt, not just Wi-Fi
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

# Show ~/Library
chflags nohidden "$HOME/Library" || true

### SCREENSHOTS ###
mkdir -p "$HOME/Documents/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Documents/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture name -string "shot"
defaults write com.apple.screencapture include-date -bool true

### MENU BAR / CONTROL CENTER ###
defaults write com.apple.menuextra.clock Show24Hour -bool true
defaults write com.apple.menuextra.clock ShowAMPM -bool false
defaults write com.apple.menuextra.clock ShowDate -int 1
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults write com.apple.menuextra.clock ShowSeconds -bool false

defaults write com.apple.controlcenter BatteryShowPercentage -bool true


defaults write com.apple.controlcenter "NSStatusItem VisibleCC Battery"    -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC WiFi"       -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Sound"      -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC Bluetooth"  -bool true
defaults write com.apple.controlcenter "NSStatusItem VisibleCC FocusModes" -bool false
defaults write com.apple.controlcenter "NSStatusItem VisibleCC NowPlaying" -bool false

#### DOCK ####
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock magnification -bool false
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock no-bouncing -bool true
defaults write com.apple.dock showhidden -bool true # hidden apps appear translucent
defaults write com.apple.dock show-process-indicators -bool true
defaults write com.apple.dock scroll-to-open -bool true
defaults write com.apple.dock enable-spring-load-actions-on-all-items -bool true
defaults write com.apple.dock expose-animation-duration -float 0.12

# Auto-hide, no delay, fast animation
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Disable all hot corners
for _c in tl tr bl br; do
  defaults write com.apple.dock "wvous-${_c}-corner" -int 1
  defaults write com.apple.dock "wvous-${_c}-modifier" -int 0
done
unset _c

if command -v dockutil >/dev/null 2>&1; then
  _dock_apps=(
    "/Applications/Firefox.app"
    "/System/Applications/Messages.app"
    "/System/Applications/Mail.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Calendar.app"
    "/Applications/Ghostty.app"
    "/System/Applications/iPhone Mirroring.app"
    "/System/Applications/Passwords.app"
    "/Applications/Cryptomator.app"
    "/System/Applications/System Settings.app"
    "/System/Applications/Siri.app"
    "/Applications/Claude.app"
    "/Applications/Gemini.app"
  )

  dockutil --remove all --no-restart >/dev/null 2>&1 || true
  for _app in "${_dock_apps[@]}"; do
    [ -e "$_app" ] || continue
    dockutil --add "$_app" --no-restart >/dev/null 2>&1 || true
  done
  if [ -d "$HOME/Documents/Projects" ]; then
    dockutil --add "$HOME/Documents/Projects" --view grid --display folder --no-restart >/dev/null 2>&1 || true
  fi
  unset _dock_apps _app
else
  echo "NOTE: dockutil not installed — skipping Dock contents (see Brewfile)" >&2
fi

### PRIVACY ###
defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false

### TIME MACHINE ###
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

if command -v defaultbrowser >/dev/null 2>&1; then
  if ! defaultbrowser 2>/dev/null | grep -q '^\* firefox'; then
    echo "NOTE: confirm the default browser dialog that is about to appear" >&2
    defaultbrowser firefox || true
  fi
else
  echo "NOTE: defaultbrowser not installed — skipping default browser (see Brewfile)" >&2
fi

### RECTANGLE ###
# Rectangle imports this file on launch (after a confirm dialog), then renames it
# and refuses symlinks — so copy, don't stow. Only re-import when the repo copy changes.
_rectangle_dir="$HOME/Library/Application Support/Rectangle"
_rectangle_src="$DOTFILES_DIR/rectangle/RectangleConfig.json"
_rectangle_sum="$(shasum -a 256 "$_rectangle_src" | cut -d' ' -f1)"
if [ "$(cat "$_rectangle_dir/.dotfiles-imported" 2>/dev/null)" != "$_rectangle_sum" ]; then
  mkdir -p "$_rectangle_dir"
  cp "$_rectangle_src" "$_rectangle_dir/RectangleConfig.json"
  echo "$_rectangle_sum" > "$_rectangle_dir/.dotfiles-imported"
  killall Rectangle >/dev/null 2>&1 || true
  sleep 1
  echo "NOTE: click Apply in the Rectangle dialog that is about to appear" >&2
  open -a Rectangle >/dev/null 2>&1 || true
fi
unset _rectangle_dir _rectangle_src _rectangle_sum

### RESTART AFFECTED SERVICES ###
for _app in Finder Dock SystemUIServer ControlCenter; do
  killall "$_app" >/dev/null 2>&1 || true
done
unset _app
