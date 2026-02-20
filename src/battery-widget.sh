#!/bin/zsh

ENABLED=$(tmux show-option -gv @tmux-tabsbar_show_battery_widget 2>/dev/null)
[[ "${ENABLED}" != "1" ]] && exit 0

BATTERY_LOW=$(tmux show-option -gv @tmux-tabsbar_battery_low_threshold 2>/dev/null)
BATTERY_LOW=${BATTERY_LOW:-21}

DISCHARGING_ICONS=("󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹")
CHARGING_ICONS=("󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅")
NOT_CHARGING_ICON="󰚥"


get_battery_info() {
    local pm_out=$(pmset -g batt)
    local perc=0
    local is_ac=0 # 0=Battery, 1=AC

    if [[ $pm_out =~ "([0-9]+)%" ]]; then
        perc=$match[1]
    fi

    if [[ $pm_out =~ "AC Power" ]] || [[ $pm_out =~ "AC attached" ]]; then
        is_ac=1
    fi

    echo "${is_ac}:${perc}"
}

IFS=":" read IS_AC PERC <<< $(get_battery_info)

idx=$(( PERC / 10 ))
(( idx >= 10 )) && idx=9
(( idx < 0 )) && idx=0


if [[ "$IS_AC" == "1" ]]; then
    ICON="${CHARGING_ICONS[$((idx + 1))]}"

    if (( PERC < BATTERY_LOW )); then
        COLOR="#[fg=yellow,bg=default,bold]"
    else
        COLOR="#[fg=green,bg=default]"
    fi

else
    ICON="${DISCHARGING_ICONS[$((idx + 1))]}"

    if (( PERC < BATTERY_LOW )); then
        COLOR="#[fg=red,bg=default,bold]"
    else
        COLOR="#[fg=green,bg=default]"
    fi
fi

echo "${COLOR}░ ${ICON} #[bg=default]${PERC}% "
