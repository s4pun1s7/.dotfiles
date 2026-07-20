#!/bin/bash

# macOS Battery Status Display Script
# Replacement for bat.sh that works on macOS
# Displays battery percentage and charging status for tmux status bar

get_battery_info() {
    local battery_info
    battery_info=$(pmset -g batt | grep -Eo '[0-9]+%')

    if [[ -z "$battery_info" ]]; then
        echo "N/A"
        return 1
    fi

    local percentage="${battery_info%\%}"
    local charging_status

    # Check if charging
    if pmset -g batt | grep -q "AC Power"; then
        charging_status="⚡"  # Charging icon
    elif pmset -g batt | grep -q "discharging"; then
        if [[ $percentage -lt 20 ]]; then
            charging_status="🔴"  # Low battery
        elif [[ $percentage -lt 50 ]]; then
            charging_status="🟡"  # Medium battery
        else
            charging_status="🟢"  # Good battery
        fi
    else
        charging_status="?"
    fi

    echo "Batt: ${percentage}% ${charging_status}"
}

# Main execution
get_battery_info
