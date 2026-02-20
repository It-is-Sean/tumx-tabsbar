#!/bin/zsh

enabled=$(tmux show-option -gv @tmux-tabsbar_show_datetime 2>/dev/null)
[[ "${enabled}" != "1" ]] && exit 0

root_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)/.."
current_dir="$(cd "$(dirname "${(%):-%x}")" && pwd)"
# 注意：确保 themes.sh 路径正确
[[ -f "$current_dir/themes.sh" ]] && source "$current_dir/themes.sh"

date_format=$(tmux show-option -gv @tmux-tabsbar_date_format 2>/dev/null)
time_format=$(tmux show-option -gv @tmux-tabsbar_time_format 2>/dev/null)

# --- 格式化处理 ---

case "$date_format" in
    ymd)  d_fmt="%y/%m/%d" ;;
    mdy)  d_fmt="%m/%d/%y" ;;
    dmy)  d_fmt="%d/%m/%y" ;;
    hide) d_fmt="" ;;
    *)    d_fmt="%y/%m/%d" ;;
esac

case "$time_format" in
    12h)  t_fmt="%I:%M %p" ;; # %I 是 12 小时制
    hide) t_fmt="" ;;
    *)    t_fmt="%H:%M" ;;    # %H 是 24 小时制
esac


final_output=""

if [[ -n "$d_fmt" ]]; then
    final_output=" $(date +"$d_fmt")"
fi

if [[ -n "$t_fmt" ]]; then
    [[ -n "$final_output" ]] && final_output="$final_output "
    final_output="$final_output $(date +"$t_fmt")"
fi

fg_color="${THEME[foreground]}"
bg_color="${THEME[bblack]}"

echo "#[fg=${fg_color},bg=${bg_color}]░ ${final_output} "
