#!/usr/bin/env bash

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_PATH="$CURRENT_DIR/src"

source $SCRIPTS_PATH/themes.sh

tmux set -g status-left-length 80
tmux set -g status-right-length 150

RESET="#[fg=${THEME[foreground]},bg=${THEME[background]},nobold,noitalics,nounderscore,nodim]"
# Highlight colors
tmux set -g mode-style "fg=${THEME[bgreen]},bg=${THEME[bblack]}"

tmux set -g message-style "bg=${THEME[blue]},fg=${THEME[bblack]}"
tmux set -g message-command-style "fg=${THEME[blue]},bg=${THEME[bblack]}"

tmux set -g pane-border-style "fg=${THEME[bblack]}"
tmux set -g pane-active-border-style "fg=${THEME[blue]}"
tmux set -g pane-border-status off

tmux set -g status-style bg="${THEME[background]}"
tmux set -g popup-border-style "fg=${THEME[blue]}"

set_default() {
  local opt="$1"
  local val="$2"
  if [ -z "$(tmux show-option -gv "$opt" 2>/dev/null)" ]; then
    tmux set-option -g "$opt" "$val"
  fi
}

# Align plugin defaults with tmux.conf when options are unset.
set_default "@tmux-tabsbar_theme" "catppuccin_mocha"
set_default "@tmux-tabsbar_transparent" "0"
set_default "@tmux-tabsbar_show_path" "1"
set_default "@tmux-tabsbar_path_format" "relative"
set_default "@tmux-tabsbar_show_battery_widget" "1"
set_default "@tmux-tabsbar_time_format" "hide"
set_default "@tmux-tabsbar_date_format" "mdy"
set_default "@tmux-tabsbar_window_id_style" "fsquare"
set_default "@tmux-tabsbar_pane_id_style" "dsquare"
set_default "@tmux-tabsbar_zoom_id_style" "dsquare"
set_default "@tmux-tabsbar_show_datetime" "1"
set_default "@tmux-tabsbar_show_git" "0"
set_default "@tmux-tabsbar_show_netspeed" "0"
set_default "@tmux-tabsbar_show_hostname" "0"
set_default "@tmux-tabsbar_show_music" "0"
set_default "@tmux-tabsbar_show_wbg" "0"

TMUX_VARS="$(tmux show -g)"

default_window_id_style="fsquare"
default_pane_id_style="dsquare"
default_zoom_id_style="dsquare"

default_terminal_icon=""
default_active_terminal_icon=""

window_id_style="$(echo "$TMUX_VARS" | grep '@tmux-tabsbar_window_id_style' | cut -d" " -f2)"
pane_id_style="$(echo "$TMUX_VARS" | grep '@tmux-tabsbar_pane_id_style' | cut -d" " -f2)"
zoom_id_style="$(echo "$TMUX_VARS" | grep '@tmux-tabsbar_zoom_id_style' | cut -d" " -f2)"
terminal_icon="$(echo "$TMUX_VARS" | grep '@tmux-tabsbar_terminal_icon' | cut -d" " -f2)"
active_terminal_icon="$(echo "$TMUX_VARS" | grep '@tmux-tabsbar_active_terminal_icon' | cut -d" " -f2)"
window_tidy="$(echo "$TMUX_VARS" | grep '@tmux-tabsbar_window_tidy_icons' | cut -d" " -f2)"

window_id_style="${window_id_style:-$default_window_id_style}"
pane_id_style="${pane_id_style:-$default_pane_id_style}"
zoom_id_style="${zoom_id_style:-$default_zoom_id_style}"
terminal_icon="${terminal_icon:-$default_terminal_icon}"
active_terminal_icon="${active_terminal_icon:-$default_active_terminal_icon}"
window_space="${window_tidy:-0}"

window_space=$([[ $window_tidy == "0" ]] && echo " " || echo "")

netspeed="#($SCRIPTS_PATH/netspeed.sh)"
cmus_status="#($SCRIPTS_PATH/music-tmux-statusbar.sh)"
git_status="#($SCRIPTS_PATH/git-status.sh #{pane_current_path})"
wb_git_status="#($SCRIPTS_PATH/wb-git-status.sh #{pane_current_path} &)"
window_number="#($SCRIPTS_PATH/custom-number.sh #I $window_id_style)"
custom_pane="#($SCRIPTS_PATH/custom-number.sh #P $pane_id_style)"
zoom_number="#($SCRIPTS_PATH/custom-number.sh #P $zoom_id_style)"
date_and_time="#($SCRIPTS_PATH/datetime-widget.sh)"
current_path="#($SCRIPTS_PATH/path-widget.sh #{pane_current_path})"
battery_status="#($SCRIPTS_PATH/battery-widget.sh)"
hostname="#($SCRIPTS_PATH/hostname-widget.sh)"
os_icon="#($SCRIPTS_PATH/os-icons.sh)"
#+--- Bars LEFT ---+
# Session name
tmux set -g status-left "#[fg=${THEME[bblack]},bg=${THEME[blue]},bold] #{?client_prefix,󰠠 ,#[dim]󰤂 }#[bold,nodim]#S$hostname "

#+--- Windows ---+
ICON_SSH="󰣀"
ICON_VIM=""  # 这是 NeoVim 的图标，如果是 Vim 可以换成 
ICON_DEFAULT=""
ICON_LOGIC="#{?#{==:#{pane_current_command},ssh},${ICON_SSH} ,#{?#{m:*vim,#{pane_current_command}},${ICON_VIM} ,${ICON_DEFAULT} }}"

TEXT_LOGIC="#{?#{==:#{pane_current_command},zsh},#{b:pane_current_path},#{pane_current_command}}"

tmux set -g window-status-current-format "$RESET#[fg=${THEME[green]},bg=${THEME[bblack]}] $window_number#[fg=${THEME[foreground]},bold,nodim]${ICON_LOGIC}${TEXT_LOGIC}#[nobold]#{?window_zoomed_flag, $zoom_number, $custom_pane} "

tmux set -g window-status-format "$RESET#[fg=${THEME[foreground]}] $window_number${RESET}${ICON_LOGIC}${TEXT_LOGIC}#{?window_last_flag,#[fg=${THEME[yellow]}],#[nobold,dim]}#{?window_zoomed_flag, $zoom_number, $custom_pane} "
#+--- Bars RIGHT ---+
tmux set -g status-right "$battery_status$current_path$cmus_status$netspeed$git_status$wb_git_status$date_and_time"
tmux set -g window-status-separator ""
