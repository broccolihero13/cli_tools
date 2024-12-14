#!/bin/bash

# Get the current working directory
TOOLS_DIR=$(pwd)

# Define aliases with placeholders for paths
DUPLICATOR_ALIAS="alias duplicator=\"ruby $TOOLS_DIR/component_duplicate.rb duplicate\""
CSV_TO_JSON_ALIAS="alias csvToJson=\"ruby $TOOLS_DIR/csv_to_json.rb convert\""
FILE_SEARCH_ALIAS="alias fileSearch=\"ruby $TOOLS_DIR/file_search.rb search\""

# Detect which shell configuration file to use
if [ -n "$ZSH_VERSION" ]; then
  RC_FILE="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
  RC_FILE="$HOME/.bashrc"
else
  echo "Unsupported shell. Please manually add the aliases to your shell's configuration file."
  exit 1
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

echo "Aliases added to '$RC_FILE':"
echo "  - $DUPLICATOR_ALIAS"
echo "  - $CSV_TO_JSON_ALIAS"
echo "  - $FILE_SEARCH_ALIAS"

# Reload the shell configuration file
source "$RC_FILE"

echo "The aliases are now available. You can use 'duplicator', 'csvToJson', and 'fileSearch' commands."
