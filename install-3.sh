#!/bin/bash

# Exit in case of any error
set -e

# Enable audio services
dinitctl enable pipewire
dinitctl enable pipewire-pulse
dinitctl enable wireplumber

# Install aur packages
yay -S --noconfirm --needed - < $HOME/Programming/aur/aur.txt

# Add virtual desktops
for i in $(seq 2 6); do
    dbus-send --session --print-reply --dest=org.kde.KWin \
        /VirtualDesktopManager \
        org.kde.KWin.VirtualDesktopManager.createDesktop \
        uint32:"$i" string:"Desktop $i"
done

# Add activities
current_activity() {
    dbus-send --session --print-reply=literal --dest=org.kde.ActivityManager \
        /ActivityManager/Activities \
        org.kde.ActivityManager.Activities.CurrentActivity | xargs
}

rename_activity() {
    local activity_id="$1" name="$2"
    dbus-send --session --print-reply=literal --dest=org.kde.ActivityManager \
        /ActivityManager/Activities \
        org.kde.ActivityManager.Activities.SetActivityName \
        string:"$activity_id" string:"$name"
}

add_activity() {
    local name="$1"
    dbus-send --session --print-reply=literal --dest=org.kde.ActivityManager \
        /ActivityManager/Activities \
        org.kde.ActivityManager.Activities.AddActivity \
        string:"$name" | xargs
}

# Get current activity id and rename to 1
ACT_1_ID=$(current_activity)
rename_activity "$ACT_1_ID" "1"

# Add 3 more activities and name them 2-4
ACT_2_ID=$(add_activity "2")
ACT_3_ID=$(add_activity "3")
ACT_4_ID=$(add_activity "4")

# Wait a a bit so the default activity shortcuts are created
sleep 3

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
kw -f kwinrc -g Desktops -k Rows -v 2

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

# kglobalshortcutsrc
# disable conflicting keyboard shortcuts
kw -f kglobalshortcutsrc -g org_kde_powerdevil -k powerProfile -v 'Battery,Battery\tMeta+B,Switch Power Profile'
kw -f kglobalshortcutsrc -g kwin -k 'Edit Tiles' -v 'none,Meta+T,Toggle Tiles Editor'
kw -f kglobalshortcutsrc -g plasmashell -k 'activate task manager entry 1' -v 'none,Meta+1,Activate Task Manager Entry 1'
kw -f kglobalshortcutsrc -g plasmashell -k 'activate task manager entry 2' -v 'none,Meta+2,Activate Task Manager Entry 2'
kw -f kglobalshortcutsrc -g plasmashell -k 'activate task manager entry 3' -v 'none,Meta+3,Activate Task Manager Entry 3'
kw -f kglobalshortcutsrc -g plasmashell -k 'activate task manager entry 4' -v 'none,Meta+4,Activate Task Manager Entry 4'
kw -f kglobalshortcutsrc -g plasmashell -k 'activate task manager entry 5' -v 'none,Meta+5,Activate Task Manager Entry 5'
kw -f kglobalshortcutsrc -g plasmashell -k 'activate task manager entry 6' -v 'none,Meta+6,Activate Task Manager Entry 6'

# enable my own keyboard shortcuts
kw -f kglobalshortcutsrc -g services -g com.mitchellh.ghostty.desktop -k _launch -v Meta+T
kw -f kglobalshortcutsrc -g services -g google-chrome.desktop -k _launch -v Meta+B
kw -f kglobalshortcutsrc -g kwin -k 'Switch to Desktop 1' -v 'Meta+1,Meta+F1\tCtrl+F1,Switch to Desktop 1'
kw -f kglobalshortcutsrc -g kwin -k 'Switch to Desktop 2' -v 'Meta+2,Meta+F2\tCtrl+F2,Switch to Desktop 2'
kw -f kglobalshortcutsrc -g kwin -k 'Switch to Desktop 3' -v 'Meta+3,Meta+F3\tCtrl+F3,Switch to Desktop 3'
kw -f kglobalshortcutsrc -g kwin -k 'Switch to Desktop 4' -v 'Meta+4,Meta+F4\tCtrl+F4,Switch to Desktop 4'
kw -f kglobalshortcutsrc -g kwin -k 'Switch to Desktop 5' -v 'Meta+5,,Switch to Desktop 5'
kw -f kglobalshortcutsrc -g kwin -k 'Switch to Desktop 6' -v 'Meta+6,,Switch to Desktop 6'
kw -f kglobalshortcutsrc -g kwin -k 'Window to Desktop 1' -v 'Meta+!,,Window to Desktop 1'
kw -f kglobalshortcutsrc -g kwin -k 'Window to Desktop 2' -v 'Meta+",,Window to Desktop 2'
kw -f kglobalshortcutsrc -g kwin -k 'Window to Desktop 3' -v 'Meta+#,,Window to Desktop 3'
kw -f kglobalshortcutsrc -g kwin -k 'Window to Desktop 4' -v 'Meta+$,,Window to Desktop 4'
kw -f kglobalshortcutsrc -g kwin -k 'Window to Desktop 5' -v 'Meta+%,,Window to Desktop 5'
kw -f kglobalshortcutsrc -g kwin -k 'Window to Desktop 6' -v 'Meta+&,,Window to Desktop 6'
kw -f kglobalshortcutsrc -g ActivityManager -k "switch-to-activity-$ACT_1_ID" -v 'Meta+Shift+J,none,Switch to activity 1'
kw -f kglobalshortcutsrc -g ActivityManager -k "switch-to-activity-$ACT_2_ID" -v 'Meta+Shift+K,none,Switch to activity 2'
kw -f kglobalshortcutsrc -g ActivityManager -k "switch-to-activity-$ACT_3_ID" -v 'Meta+Shift+L,none,Switch to activity 3'
kw -f kglobalshortcutsrc -g ActivityManager -k "switch-to-activity-$ACT_4_ID" -v 'Meta+Shift+Ö,none,Switch to activity 4'

cat << EOF
Script ran successfully.

These are some things that need to be done manually:
1. Disable mouse acceleration and enable touchpad natural scrolling.
2. Change screen scale to 125%.
3. Change desktop session to always start with an empty session.
4. Update taskbar apps and style.
5. Add a keyboard shortcut to run swirl.

These might also be necessary:
1. Create mountpoints for other disks.
2. Setup printer.
3. Configure wallpapers for each activity.
4. Adjust region settings.

For all changes to apply, restart the system.
EOF
