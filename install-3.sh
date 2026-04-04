#!/bin/bash

# Exit in case of any error
set -e

# Enable audio services
dinitctl enable pipewire
dinitctl enable pipewire-pulse
dinitctl enable wireplumber

# Install aur packages
yay -S --noconfirm --needed - < $HOME/Programming/aur/aur.txt

# Custom function to write configs much easier
kw() {
    local file="" key="" val="" type=""
    local groups=()

    # parse named arguments
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -f|--file)  file="$2"; shift 2 ;;
            -k|--key)   key="$2";  shift 2 ;;
            -v|--value) val="$2";  shift 2 ;;
            -t|--type)  type="$2"; shift 2 ;;
            -g|--group) groups+=("--group" "$2"); shift 2 ;;
            *) echo "Unknown parameter: $1"; return 1 ;;
        esac
    done

    # create the command
    local cmd=(kwriteconfig6 --notify --file "$file" "${groups[@]}" --key "$key" "$val")

    # add the type if it exists
    [[ -n "$type" ]] && cmd+=(--type "$type")

    # run the command
    "${cmd[@]}"
}

# Apply some kde plasma settings
# kcminputrc
kw -f kcminputrc -g Keyboard -k NumLock -v 0
kw -f kcminputrc -g Keyboard -k RepeatDelay -v 300
kw -f kcminputrc -g Keyboard -k RepeatRate -v 50

# kxkbrc
kw -f kxkbrc -g Layout -k LayoutList -v pro
kw -f kxkbrc -g Layout -k Options -v caps:swapescape
kw -f kxkbrc -g Layout -k ResetOldOptions -v true -t bool
kw -f kxkbrc -g Layout -k Use -v true -t bool

# kwinrc
kw -f kwinrc -g Effect-overview -k BorderActivate -v 9
kw -f kwinrc -g Plugins -k shakecursorEnabled -v false -t bool

# kdeglobals
kw -f kdeglobals -g KDE -k AnimationDurationFactor -v 0
kw -f kdeglobals -g KDE -k SingleClick -v true -t bool

# krunnerrc
kw -f krunnerrc -g Plugins -k baloosearchEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k browserhistoryEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k browsertabsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k helprunnerEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_appstreamEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_bookmarksrunnerEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_charrunnerEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_colorsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_dictionaryEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_katesessionsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_killEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_konsoleprofilesEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_kwinEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_placesrunnerEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_plasma-desktopEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_powerdevilEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_recentdocumentsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_sessionsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_spellcheckEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_systemsettingsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k krunner_webshortcutsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k locationsEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k org.kde.activities2Enabled -v false -t bool
kw -f krunnerrc -g Plugins -k org.kde.datetimeEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k unitconverterEnabled -v false -t bool
kw -f krunnerrc -g Plugins -k windowsEnabled -v false -t bool

# baloofilerc
kw -f baloofilerc -g General -k "only basic indexing" -v true -t bool

# powerdevilrc
kw -f powerdevilrc -g Battery -g SuspendAndShutdown -k SleepMode -v 3
kw -f powerdevilrc -g LowBattery -g SuspendAndShutdown -k SleepMode -v 3

# dolphinrc
kw -f dolphinrc -g General -k RememberOpenedTabs -v false -t bool
kw -f dolphinrc -g VersionControl -k enabledPlugins -v Git
