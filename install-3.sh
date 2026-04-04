#!/bin/bash

# Exit in case of any error
set -e

# Enable audio services
dinitctl enable pipewire
dinitctl enable pipewire-pulse
dinitctl enable wireplumber

# Install aur packages
yay -S --noconfirm --needed - < $HOME/Programming/aur/aur.txt

# Apply some kde plasma settings
# kcminputrc
kwriteconfig6 --file="kcminputrc" --group="Keyboard" --key="NumLock" 0
kwriteconfig6 --file="kcminputrc" --group="Keyboard" --key="RepeatDelay" 300
kwriteconfig6 --file="kcminputrc" --group="Keyboard" --key="RepeatRate" 50

# kxkbrc
kwriteconfig6 --file="kxkbrc" --group="Layout" --key="LayoutList" "pro"
kwriteconfig6 --file="kxkbrc" --group="Layout" --key="Options" "caps:swapescape"
kwriteconfig6 --file="kxkbrc" --group="Layout" --key="ResetOldOptions" --type=bool true
kwriteconfig6 --file="kxkbrc" --group="Layout" --key="Use" --type=bool true

# kwinrc
kwriteconfig6 --file="kwinrc" --group="Effect-overview" --key="BorderActivate" 9
kwriteconfig6 --file="kwinrc" --group="Plugins" --key="shakecursorEnabled" --type="bool" false

# kdeglobals
kwriteconfig6 --file="kdeglobals" --group="KDE" --key="AnimationDurationFactor" 0
kwriteconfig6 --file="kdeglobals" --group="KDE" --key="SingleClick" --type="bool" true

# krunnerrc
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="baloosearchEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="browserhistoryEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="browsertabsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="helprunnerEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_appstreamEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_bookmarksrunnerEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_charrunnerEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_colorsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_dictionaryEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_katesessionsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_killEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_konsoleprofilesEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_kwinEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_placesrunnerEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_plasma-desktopEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_powerdevilEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_recentdocumentsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_sessionsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_spellcheckEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_systemsettingsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="krunner_webshortcutsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="locationsEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="org.kde.activities2Enabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="org.kde.datetimeEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="unitconverterEnabled" --type="bool" false
kwriteconfig6 --file="krunnerrc" --group="Plugins" --key="windowsEnabled" --type="bool" false

# baloofilerc
kwriteconfig6 --file="baloofilerc" --group="General" --key="only basic indexing" --type="bool" true

# powerdevilrc
kwriteconfig6 --file="powerdevilrc" --group="Battery" --group="SuspendAndShutdown" --key="SleepMode" 3
kwriteconfig6 --file="powerdevilrc" --group="LowBattery" --group="SuspendAndShutdown" --key="SleepMode" 3

# dolphinrc
kwriteconfig6 --file="dolphinrc" --group="General" --key="RememberOpenedTabs" --type="bool" false
kwriteconfig6 --file="dolphinrc" --group="VersionControl" --key="enabledPlugins" "Git"
