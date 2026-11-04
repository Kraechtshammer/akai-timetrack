#!/usr/bin/env bash
# Dev container, emulator running: creates a local (not synced) test calendar "AKAI Schichten"
# with two event colours, because the emulator has no Google account and so no calendars.
acct='account_name=test@local&account_type=LOCAL&caller_is_syncadapter=true'
adb shell "content insert --uri 'content://com.android.calendar/calendars?$acct' \
  --bind account_name:s:test@local --bind account_type:s:LOCAL --bind name:s:akai \
  --bind calendar_displayName:s:'AKAI Schichten' --bind calendar_color:i:-16738680 \
  --bind calendar_access_level:i:700 --bind ownerAccount:s:test@local --bind sync_events:i:1 \
  --bind visible:i:1 --bind calendar_timezone:s:Europe/Berlin"
adb shell "content insert --uri 'content://com.android.calendar/colors?$acct' \
  --bind account_name:s:test@local --bind account_type:s:LOCAL --bind color_type:i:1 \
  --bind color_index:s:11 --bind color:i:-2350809"
adb shell "content insert --uri 'content://com.android.calendar/colors?$acct' \
  --bind account_name:s:test@local --bind account_type:s:LOCAL --bind color_type:i:1 \
  --bind color_index:s:7 --bind color:i:-12134693"
adb shell content query --uri content://com.android.calendar/calendars --projection _id:calendar_displayName:account_name
adb shell content query --uri content://com.android.calendar/colors --projection color_index:color:account_name
