#!/bin/bash

# prettypwd.sh - A prettier alternative to the standard 'pwd' command
#
# Description:
#   This script displays the current working directory with enhanced formatting,
#   and shows how many directory levels deep you are from your home directory.
#
# Usage:
#   ./prettypwd.sh
#
# Note:
#   This script uses Nerd Font icons. For best results,
#   please use the MesloLGS NF font in your terminal.

# ANSI color codes
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Font icons (Nerd Font Unicode code points)
HOME_ICON=$'\uf015'        # fa-home
DIR_ICON=$'\uf07b'         # fa-folder
OPEN_DIR_ICON=$'\uf07c'    # fa-folder-open
DEPTH_ICON=$'\uf178'       # fa-long-arrow-right
ARROW_ICON=$'\uf061'       # fa-arrow-right (smaller than long-arrow)
CURRENT_ICON=$'\uf192'     # fa-dot-circle-o

CURRENT_DIR=$(pwd)

TERM_WIDTH=$(tput cols)
CONTENT_WIDTH=$((TERM_WIDTH - 4)) 

TITLE_TEXT=" Pretty PWD "
TITLE_LEN=${#TITLE_TEXT}
LEFT_PADDING=$(( (CONTENT_WIDTH - TITLE_LEN) / 2 ))
RIGHT_PADDING=$(( CONTENT_WIDTH - TITLE_LEN - LEFT_PADDING ))
LEFT_FRAME=$(printf '═%.0s' $(seq 1 $LEFT_PADDING))
RIGHT_FRAME=$(printf '═%.0s' $(seq 1 $RIGHT_PADDING))

echo -e "${BOLD}${CYAN}╔${LEFT_FRAME}${TITLE_TEXT}${RIGHT_FRAME}╗${RESET}"

if [[ "$CURRENT_DIR" == "$HOME"* ]]; then
    PRETTY_PATH="${HOME_ICON} ~${CURRENT_DIR#$HOME}"
    
    # Calculate depth
    if [[ "$CURRENT_DIR" == "$HOME" ]]; then
        DEPTH=0
        DEPTH_MESSAGE="${YELLOW}${HOME_ICON} In home directory${RESET}"
    else
        REL_PATH=${CURRENT_DIR#$HOME/}
        DEPTH=$(echo "$REL_PATH" | tr -cd '/' | wc -c)
        ((DEPTH++))
        
        DEPTH_INDICATOR=""
        for ((i=1; i<=DEPTH; i++)); do
            DEPTH_INDICATOR="${DEPTH_INDICATOR}${DEPTH_ICON} "
        done
        DEPTH_MESSAGE="${YELLOW}${DEPTH_INDICATOR}${DEPTH} level$([ $DEPTH -ne 1 ] && echo "s") from home${RESET}"
    fi
else
    PRETTY_PATH="${OPEN_DIR_ICON} $CURRENT_DIR"
    DEPTH_MESSAGE="${YELLOW}${OPEN_DIR_ICON} Outside home directory${RESET}"
fi

echo -e " ${BOLD}Location:${RESET} ${GREEN}$PRETTY_PATH${RESET}"
echo -e " ${BOLD}Depth:${RESET} $DEPTH_MESSAGE"
echo -e " ${BOLD}Path breakdown:${RESET}"

IFS='/' read -ra DIR_COMPONENTS <<< "$CURRENT_DIR"
PATH_SO_FAR=""
VALID_COMPONENTS=()

for COMPONENT in "${DIR_COMPONENTS[@]}"; do
    if [[ -n "$COMPONENT" ]]; then
        VALID_COMPONENTS+=("$COMPONENT")
    fi
done

VALID_COUNT=${#VALID_COMPONENTS[@]}
CURRENT_IDX=0

echo -e " ${BLUE}╭─ Path Structure ${RESET}"
for COMPONENT in "${VALID_COMPONENTS[@]}"; do
    PATH_SO_FAR="$PATH_SO_FAR/$COMPONENT"
    ((CURRENT_IDX++))
    
    if [[ "$PATH_SO_FAR" == "$HOME" ]]; then
        ICON="${HOME_ICON}"
        DISPLAY="(~)"
    elif [[ $CURRENT_IDX -eq $VALID_COUNT ]]; then
        # Current directory
        ICON="${CURRENT_ICON}"
        DISPLAY="($PATH_SO_FAR)"
    else
        ICON="${DIR_ICON}"
        DISPLAY="($PATH_SO_FAR)"
    fi
    
    ARROW_INDENT=""
    for ((i=1; i<CURRENT_IDX; i++)); do
        ARROW_INDENT="${ARROW_INDENT}${ARROW_ICON} "
    done
    
    if [[ $CURRENT_IDX -eq $VALID_COUNT ]]; then
        PREFIX="${BLUE}╰─ ${RESET}"
        FOLDER_ICON="${OPEN_DIR_ICON}" 
    else
        PREFIX="${BLUE}├─ ${RESET}"
        FOLDER_ICON="${DIR_ICON}"
    fi
    
    if [[ $CURRENT_IDX -gt 1 ]]; then
        echo -e " ${PREFIX}${ARROW_INDENT}${YELLOW}${FOLDER_ICON} ${COMPONENT}${RESET}  ${CYAN}${DISPLAY}${RESET}"
    else
        echo -e " ${PREFIX}${YELLOW}${FOLDER_ICON} ${COMPONENT}${RESET}  ${CYAN}${DISPLAY}${RESET}"
    fi
    
    if [[ $CURRENT_IDX -lt $VALID_COUNT ]]; then
        echo -e " ${BLUE}│${RESET}"
    fi
done

BOTTOM_FRAME=$(printf '═%.0s' $(seq 1 $CONTENT_WIDTH))
echo -e "${BOLD}${CYAN}╚${BOTTOM_FRAME}╝${RESET}"