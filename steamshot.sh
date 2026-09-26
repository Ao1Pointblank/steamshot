#!/bin/bash

#dependencies:
#bash, util-linux (getopt), coreutils (mkdir, mv, sort, head), findutils, grep, curl, sed, inotify-tools (for daemon mode only)

SCREENSHOT_DIR="/home/$USER/Pictures/Steam Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# Parse command line options
TEMP=$(getopt -o hiud --long help,interactive,undo,daemon -n 'sort_screenshots.sh' -- "$@")
eval set -- "$TEMP"

HELP=false
INTERACTIVE=false
UNDO=false
DAEMON=false

while true; do
  case "$1" in
    -h | --help ) HELP=true; shift ;;
    -i | --interactive ) INTERACTIVE=true; shift ;;
    -u | --undo ) UNDO=true; shift ;;
    -d | --daemon ) DAEMON=true; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ "$HELP" = true ]; then
  echo "Usage: $0 [-h|--help] [-i|--interactive] [-u|--undo] [-d|--daemon]"
  echo "  -h, --help        Show this help message"
  echo "  -i, --interactive  Show changes before applying"
  echo "  -u, --undo         Move all screenshots back to main folder"
  echo "  -d, --daemon       Start an inotifywait event watcher to run the sorter automatically"
  exit 0
fi

if [ "$UNDO" = true ]; then
  cd "$SCREENSHOT_DIR" || exit 1
  find . -mindepth 2 -type f -name "*.png" -exec mv {} . \;
  echo "Screenshots moved back to main directory."
  exit 0
fi

if [ "$DAEMON" = true ]; then
  inotifywait -m -e create --format '%f' "$SCREENSHOT_DIR" | while read file; do
    echo "Detected: $file"
    "$0" &
  done &
  echo "Daemon started with PID $!"
  exit 0
fi

cd "$SCREENSHOT_DIR" || exit 1

# Extract unique Game IDs
readarray -t ids < <(printf '%s\n' *.png | grep -oE '^[0-9]+' | sort -u)

# Debug: Print detected IDs
echo "Detected Game IDs:"
printf '  %s\n' "${ids[@]}"
echo "Total unique IDs: ${#ids[@]}"

if [ "$INTERACTIVE" = true ]; then
  read -p "Press Enter to continue with API lookups..."
fi

# Process each unique ID
for game_id in "${ids[@]}"; do
  echo "Fetching name for App ID: $game_id..."
#  name=$(curl -s "https://store.steampowered.com/api/appdetails?appids=$game_id" | jq -r ".[\"$game_id\"].data.name // \"$game_id\"")   ##broken method; steam updated API
#  name=$(curl -s "https://store.steampowered.com/api/appdetails?appids=$game_id" | head -c 100 | grep -o '"name":"[^"]*"' | head -1 | sed 's/"name":"//;s/"$//') ##fixed method, but uses multi process
  name=$(curl -s "https://store.steampowered.com/api/appdetails?appids=$game_id" | head -c 100 | sed -n 's/.*"name":"\([^"]*\)".*/\1/p')  ##fastest fixed method; head command to close curl connection after 100B
  safe_name=$(echo "$name" | sed 's/[\\/*?"<>|]/_/g')
  mkdir -p "$safe_name"

  if [ "$INTERACTIVE" = true ]; then
    echo "Moving ${game_id}_*.png -> $safe_name/"
    read -p "Press Enter to continue..."
  fi
  mv ${game_id}_*.png "$safe_name/" 2>/dev/null || true
done
