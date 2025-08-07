#!/bin/bash

# USER RENAMER SCRIPT
# USAGE:
#   user_rename.sh <old_name> <new_name>
#   user_rename.sh --dry-run <old_name> <new_name>
#   user_rename.sh --help

logger() {
  local LEVEL="$1"
  local MESSAGE="$2"
  echo "$(date -Iseconds) [$LEVEL] $MESSAGE"
}

user_rename() {
  local OLD_NAME=$1
  local NEW_NAME=$2
  local DRY_RUN=$3

  logger "INFO" "Starting rename from '$OLD_NAME' to '$NEW_NAME'..."

  # Sanity check: avoid renaming the current user
  local CURRENT_USER
  CURRENT_USER=$(whoami)
  if [[ "$CURRENT_USER" == "$OLD_NAME" ]]; then
    logger "ERROR" "Refusing to rename the currently logged-in user '$OLD_NAME'."
    exit 1
  fi

  # Check if old user exists
  if ! id "$OLD_NAME" &>/dev/null; then
    logger "ERROR" "User '$OLD_NAME' does not exist."
    exit 1
  fi

  # Check if new user already exists
  if id "$NEW_NAME" &>/dev/null; then
    logger "ERROR" "User '$NEW_NAME' already exists."
    exit 1
  fi

  if [[ "$DRY_RUN" == "true" ]]; then
    logger "DRY-RUN" "Would run: usermod --login '$NEW_NAME' '$OLD_NAME'"
    logger "DRY-RUN" "Would run: usermod --move-home --home '/home/$NEW_NAME' '$NEW_NAME'"
    logger "DRY-RUN" "Would run: groupmod --new-name '$NEW_NAME' '$OLD_NAME'"
    logger "SUCCESS" "Dry-run completed for user rename from '$OLD_NAME' to '$NEW_NAME'."
    return
  fi

  # Rename user
  if usermod --login "$NEW_NAME" "$OLD_NAME"; then
    logger "INFO" "Login name changed from '$OLD_NAME' to '$NEW_NAME'."
  else
    logger "ERROR" "Failed to change login name."
    exit 1
  fi

  # Move and rename home directory
  if usermod --move-home --home "/home/$NEW_NAME" "$NEW_NAME"; then
    logger "INFO" "Home directory moved to '/home/$NEW_NAME'."
  else
    logger "ERROR" "Failed to move home directory."
    exit 1
  fi

  # Rename group
  if groupmod --new-name "$NEW_NAME" "$OLD_NAME"; then
    logger "INFO" "Group renamed from '$OLD_NAME' to '$NEW_NAME'."
  else
    logger "ERROR" "Failed to rename group."
    exit 1
  fi

  logger "SUCCESS" "User '$OLD_NAME' successfully renamed to '$NEW_NAME'."
}

# Argument parsing
DRY_RUN="false"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  echo "Usage:"
  echo "  $0 <old_username> <new_username>"
  echo "  $0 --dry-run <old_username> <new_username>"
  echo "  $0 --help"
  exit 0
elif [[ "$1" == "--dry-run" ]]; then
  if [[ $# -ne 3 ]]; then
    logger "ERROR" "Dry-run mode requires OLD and NEW username."
    echo "Try '$0 --help' for usage."
    exit 1
  fi
  DRY_RUN="true"
  OLD_NAME="$2"
  NEW_NAME="$3"
elif [[ $# -ne 2 ]]; then
  logger "ERROR" "Invalid number of arguments."
  echo "Try '$0 --help' for usage."
  exit 1
else
  OLD_NAME="$1"
  NEW_NAME="$2"
fi

# Run the function
user_rename "$OLD_NAME" "$NEW_NAME" "$DRY_RUN"
