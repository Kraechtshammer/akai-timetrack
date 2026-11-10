#!/usr/bin/env bash
# Dev container, emulator running: creates a local (not synced) test calendar "AKAI Schichten"
# with Google's 11 event colours, because the emulator has no Google account and so no calendars.
# Safe to run again: the calendar and each colour are only added when missing.
acct='account_name=test@local&account_type=LOCAL&caller_is_syncadapter=true'

if ! adb shell content query --uri content://com.android.calendar/calendars \
    --projection account_name | grep -q 'account_name=test@local'; then
  adb shell "content insert --uri 'content://com.android.calendar/calendars?$acct' \
    --bind account_name:s:test@local --bind account_type:s:LOCAL --bind name:s:akai \
    --bind calendar_displayName:s:'AKAI Schichten' --bind calendar_color:i:-16738680 \
    --bind calendar_access_level:i:700 --bind ownerAccount:s:test@local --bind sync_events:i:1 \
    --bind visible:i:1 --bind calendar_timezone:s:Europe/Berlin"
fi

# Google Calendar's event colours (key: ARGB), as a Google account offers them:
# 1 Lavender, 2 Sage, 3 Grape, 4 Flamingo, 5 Banana, 6 Tangerine, 7 Peacock,
# 8 Graphite, 9 Blueberry, 10 Basil, 11 Tomato.
colors='1:FFA4BDFC 2:FF7AE7BF 3:FFDBADFF 4:FFFF887C 5:FFFBD75B 6:FFFFB878
7:FF46D6DB 8:FFE1E1E1 9:FF5484ED 10:FF51B749 11:FFDC2127'
existing=$(adb shell content query --uri content://com.android.calendar/colors \
  --projection color_index:account_name)
for entry in $colors; do
  key=${entry%%:*}
  color=$(( 0x${entry#*:} - 0x100000000 )) # the provider wants a signed int
  if grep -q "color_index=$key, account_name=test@local" <<<"$existing"; then continue; fi
  adb shell "content insert --uri 'content://com.android.calendar/colors?$acct' \
    --bind account_name:s:test@local --bind account_type:s:LOCAL --bind color_type:i:1 \
    --bind color_index:s:$key --bind color:i:$color"
done

adb shell content query --uri content://com.android.calendar/calendars --projection _id:calendar_displayName:account_name
adb shell content query --uri content://com.android.calendar/colors --projection color_index:color:account_name
