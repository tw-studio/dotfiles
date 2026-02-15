# macOS Setup Preferences

1. System Settings
    1. Keyboard > Keyboard Shortcuts > Caps Lock = Escape
    2. Desktop & Dock
        1. Disable “Show suggested and recent apps in Dock”
        2. Disable “Click wallpaper to show desktop”
        3. Mission Control > Disable Automatically rearrange Spaces by recent
        4. Hot Corners
            1. Disable All
            2. Old:
                1. Lower-right desktop
                2. Lower-left all windows / Mission Control
                3. Disable Quick Note
        5. Shortcuts… > disable all
    3. iCloud > iCloud
        1. Disable multiple services
2. Change Screenshots directory
    1. mkdir -p “$HOME/Desktop/Screenshots”
    2. defaults write com.apple.screencapture location “$HOME/Desktop/Screenshots”
    3. killall SystemUIServer 2>/dev/null
3. Dock:
    1. Right position
    2. Remove icons
    3. Add Screenshots directory
4. Widgets: Remove
5. Safari
    1. General
        1. Opens with: A new private window
        2. Remove history items: After one day
    2. Tabs
        1. Enable “Always show website titles in tabs”
        2. Disable “Show color in tab bar”
    3. Autofill
        1. Disable all AutoFill checkboxes
    4. Security
        1. Enable Warn before HTTP
    5. Privacy
        1. Enable “Require password to view locked tabs”
    6. Advanced
        1. Disable “Allow privacy-preserving measurement of ad effectiveness”
        2. Enable “Show features for web developers”
6. Hide Desktop icons
    1. defaults write com.apple.finder CreateDesktop -bool false
    2. killall Finder
7. Set Safari Zoom level to 85%
    1. defaults write "$HOME/Library/Preferences/com.apple.Safari.plist" DefaultPageZoom -string "0.85"
8. Set Wallpaper
    1. Top options:
        1. Sonoma evening
        2. Himalayan Peaks
        3. abstract
