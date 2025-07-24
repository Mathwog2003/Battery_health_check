#!/bin/bash

# battery-health.sh — Check battery health and status

BAT_PATH="/sys/class/power_supply/BAT0"
AC_PATH="/sys/class/power_supply/AC"

# Check if battery path exists
if [ ! -d "$BAT_PATH" ]; then
  echo "❌ No battery detected."
  exit 1
fi

# Basic info
STATUS=$(cat "$BAT_PATH/status")
CAPACITY=$(cat "$BAT_PATH/capacity")
CURRENT_NOW=$(cat "$BAT_PATH/current_now" 2>/dev/null)
VOLTAGE_NOW=$(cat "$BAT_PATH/voltage_now" 2>/dev/null)
CHARGE_NOW=$(cat "$BAT_PATH/charge_now" 2>/dev/null)
CHARGE_FULL=$(cat "$BAT_PATH/charge_full" 2>/dev/null)
CHARGE_DESIGN=$(cat "$BAT_PATH/charge_full_design" 2>/dev/null)

# Calculate health (if possible)
if [ -n "$CHARGE_DESIGN" ] && [ -n "$CHARGE_FULL" ]; then
  HEALTH=$((100 * CHARGE_FULL / CHARGE_DESIGN))
else
  HEALTH="Unknown"
fi

# Show output
echo "🔋 Battery Health Report"
echo "------------------------"
echo "Status     : $STATUS"
echo "Charge     : $CAPACITY%"
if [ "$HEALTH" != "Unknown" ]; then
  echo "Health     : $HEALTH% (based on design vs full capacity)"
fi
if [ -n "$CURRENT_NOW" ]; then
  echo "Current    : $((CURRENT_NOW / 1000)) mA"
fi
if [ -n "$VOLTAGE_NOW" ]; then
  echo "Voltage    : $((VOLTAGE_NOW / 1000000)) V"
fi

# Estimate time remaining using upower (optional)
if command -v upower >/dev/null 2>&1; then
  DEVICE=$(upower -e | grep battery | head -n1)
  TIME_LEFT=$(upower -i "$DEVICE" | grep -E "time to empty|time to full" | awk -F: '{print $2}' | xargs)
  if [ -n "$TIME_LEFT" ]; then
    echo "Time Left  : $TIME_LEFT"
  fi
fi

# Suggest install of `acpi` for more output
if ! command -v acpi >/dev/null 2>&1; then
  echo "ℹ️  Tip: Install 'acpi' for more details: sudo apt install acpi"
fi
