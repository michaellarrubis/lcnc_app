#!/bin/bash

source "${PWD}/scripts/utils/helpers.sh"

echo ""
if [ "$#" -lt 2 ]; then
  echo ""
  echo "[API] ❌: Seems like you didn't follow the needed format!"
  echo "---------------------------------------------------------------------------"
  echo "|                                                                          |"
  echo "|  gen_app <table_name> <column_name>:<data_type>:[optional<field_type>]   |"
  echo "|                                                                          |"
  echo "---------------------------------------------------------------------------"
  exit 1
fi

table_name="$1"

if ! to_snake_case "$table_name"; then
  echo "[API] ❌: The table name must be in a snake_case."
  exit 1
fi

log_dir="${PWD}/scripts/logs"
if [ ! -d "$log_dir" ]; then
  mkdir -p "$log_dir";
fi

if [ ! -f "$log_dir" ]; then
  mkdir -p "$log_dir";
fi

echo "Logging..."
echo "$@" > "$log_dir/${table_name}.txt"