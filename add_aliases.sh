#!/bin/bash

# Get the current working directory
TOOLS_DIR=$(pwd)

# Define aliases with placeholders for paths
DUPLICATOR_ALIAS="alias duplicator=\"ruby $TOOLS_DIR/component_duplicate.rb duplicate\""
CSV_TO_JSON_ALIAS="alias csvToJson=\"ruby $TOOLS_DIR/csv_to_json.rb convert\""
FILE_SEARCH_ALIAS="alias fileSearch=\"ruby $TOOLS_DIR/file_search.rb search\""
API_LOOPER="alias apiLooper=\"ruby $TOOLS_DIR/api_looper.rb loop\""
COMMON_IDS="alias commonIds=\"ruby $TOOLS_DIR/common_ids.rb common_ids\""
JSON_DIFF="alias jsonDiff=\"ruby $TOOLS_DIR/json_diff.rb diff\""
CSV_XLSX_DIFF="alias csvXlsxDiff=\"ruby $TOOLS_DIR/csv_xlsx_diff.rb diff\""
VIDEO_TO_GIF="alias videoToGif=\"ruby $TOOLS_DIR/video_to_gif.rb convert\""

# Detect which shell configuration file to use
if [ -n "$ZSH_VERSION" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  RC_FILE="$HOME/.bashrc"
else
  echo "Unsupported shell. Please manually add the aliases to your shell's configuration file."
  exit 1
fi

# Check for videoToGif support tools (ffmpeg / ffmpeg-full) before establishing its alias
ADD_VIDEO_TO_GIF=true
FFMPEG_BIN=""
if [ -x "/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg" ]; then
  FFMPEG_BIN="/opt/homebrew/opt/ffmpeg-full/bin/ffmpeg"
elif [ -x "/usr/local/opt/ffmpeg-full/bin/ffmpeg" ]; then
  FFMPEG_BIN="/usr/local/opt/ffmpeg-full/bin/ffmpeg"
elif command -v ffmpeg >/dev/null 2>&1; then
  FFMPEG_BIN="ffmpeg"
fi

install_ffmpeg_basic() {
  if command -v brew >/dev/null 2>&1; then
    brew install ffmpeg
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y ffmpeg
  else
    echo "Could not find Homebrew or apt-get. Please install ffmpeg manually."
    return 1
  fi
}

install_ffmpeg_full() {
  if command -v brew >/dev/null 2>&1; then
    brew install ffmpeg-full
  elif command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update && sudo apt-get install -y ffmpeg libavfilter-extra
  else
    echo "Could not find Homebrew or apt-get. Please install ffmpeg with libfreetype support manually."
    return 1
  fi
}

if [ -z "$FFMPEG_BIN" ]; then
  echo ""
  echo "The 'videoToGif' tool requires ffmpeg."
  echo "  1) Install ffmpeg (smaller install; converts video to GIF without text overlay)"
  echo "  2) Install ffmpeg-full (larger install; includes custom text overlay support)"
  echo "  3) Skip (do not install ffmpeg or add the 'videoToGif' alias)"
  printf "Choose an option [1/2/3]: "
  read -r ffmpeg_choice
  case "$ffmpeg_choice" in
    1)
      if ! install_ffmpeg_basic; then
        ADD_VIDEO_TO_GIF=false
      fi
      ;;
    2)
      if ! install_ffmpeg_full; then
        ADD_VIDEO_TO_GIF=false
      fi
      ;;
    *)
      echo "Skipping ffmpeg installation and 'videoToGif' alias."
      ADD_VIDEO_TO_GIF=false
      ;;
  esac
elif ! "$FFMPEG_BIN" -filters 2>/dev/null | grep -q drawtext; then
  echo ""
  echo "Standard ffmpeg is installed, but it does not include the 'drawtext' filter for custom text overlays in 'videoToGif'."
  echo "(If you skip this, 'videoToGif' will still work and will simply omit the custom text prompt.)"
  printf "Would you like to install ffmpeg-full for text overlay support? [y/N]: "
  read -r text_choice
  case "$text_choice" in
    [yY]|[yY][eE][sS])
      install_ffmpeg_full
      ;;
    *)
      echo "Continuing with standard ffmpeg (without text overlay prompt)."
      ;;
  esac
fi

# Backup the RC file before modifying it
BACKUP_FILE="${RC_FILE}.backup.$(date +%Y%m%d%H%M%S)"
if [ -f "$RC_FILE" ]; then
  cp "$RC_FILE" "$BACKUP_FILE"
  echo "Backup of '$RC_FILE' created at '$BACKUP_FILE'."
else
  echo "No existing RC file found. Creating a new one at '$RC_FILE'."
  touch "$RC_FILE"
fi

# Add aliases to the RC file
echo "" >> "$RC_FILE"
echo "# CLI Tools aliases" >> "$RC_FILE"
echo "$DUPLICATOR_ALIAS" >> "$RC_FILE"
echo "$CSV_TO_JSON_ALIAS" >> "$RC_FILE"
echo "$FILE_SEARCH_ALIAS" >> "$RC_FILE"
echo "$API_LOOPER" >> "$RC_FILE"
echo "$COMMON_IDS" >> "$RC_FILE"
echo "$JSON_DIFF" >> "$RC_FILE"
echo "$CSV_XLSX_DIFF" >> "$RC_FILE"
if [ "$ADD_VIDEO_TO_GIF" = true ]; then
  echo "$VIDEO_TO_GIF" >> "$RC_FILE"
fi

echo "Aliases added to '$RC_FILE':"
echo "  - $DUPLICATOR_ALIAS"
echo "  - $CSV_TO_JSON_ALIAS"
echo "  - $FILE_SEARCH_ALIAS"
echo "  - $API_LOOPER"
echo "  - $COMMON_IDS"
echo "  - $JSON_DIFF"
echo "  - $CSV_XLSX_DIFF"
if [ "$ADD_VIDEO_TO_GIF" = true ]; then
  echo "  - $VIDEO_TO_GIF"
fi

# Reload the shell configuration file
source "$RC_FILE"

if [ "$ADD_VIDEO_TO_GIF" = true ]; then
  echo "The aliases are now available. You can use 'duplicator', 'csvToJson', 'fileSearch', 'apiLooper', 'commonIds', 'jsonDiff', 'csvXlsxDiff', and 'videoToGif' commands."
else
  echo "The aliases are now available. You can use 'duplicator', 'csvToJson', 'fileSearch', 'apiLooper', 'commonIds', 'jsonDiff', and 'csvXlsxDiff' commands."
fi
