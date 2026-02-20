#!/usr/bin/env zsh

# check if enabled
ENABLED=$(tmux show-option -gv @tmux-tabsbar_show_path 2>/dev/null)
[[ ${ENABLED} -ne 1 ]] && exit 0

# Imports
ROOT_DIR="$(cd "$(dirname "${0:A}")" && pwd)/.."

PATH_FORMAT=$(tmux show-option -gv @tmux-tabsbar_path_format 2>/dev/null) # full | relative
RESET="#[fg=brightwhite,bg=#15161e,nobold,noitalics,nounderscore,nodim]"

current_path="${1}"
default_path_format="relative"
PATH_FORMAT="${PATH_FORMAT:-$default_path_format}"

# --- Fish Shell Style Logic ---

if [[ "${current_path}" == ${HOME}* ]]; then
  current_path="~${current_path#$HOME}"
fi

if [[ ${PATH_FORMAT} == "relative" ]]; then
  local parts=("${(@s:/:)current_path}")
  local shortened_parts=()
  local count=${#parts}

  for (( i=1; i<=count; i++ )); do
    local part="${parts[$i]}"

    if (( i == count )); then
      shortened_parts+=("$part")

    elif [[ -z "$part" || "$part" == "~" ]]; then
      shortened_parts+=("$part")

    elif [[ "$part" == .* ]]; then
      shortened_parts+=("${part[0,2]}")

    else
      shortened_parts+=("${part[0,1]}")
    fi
  done

  current_path="${(j:/:)shortened_parts}"
fi

echo "#[fg=blue,bg=default]░   ${RESET}#[fg=blue,bg=default]${current_path} "
