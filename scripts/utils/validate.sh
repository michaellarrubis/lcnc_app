#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"

validate_argument() {
  if [ "$#" -lt 2 ]; then
    echo "[API] ❌ Usage: [gen_*] <table_name> <column_name>:<data_type>:[optional<field_type>]"
    exit 1
  fi

  initial_table_name="$1"
  if ! to_snake_case "$initial_table_name"; then
    echo "[API] ❌: table_name must be in a snake_case."
    exit 1
  fi

  if [ ! -d "${PWD}/lcnc_api/src/__generated__" ]; then
    mkdir -p "${PWD}/lcnc_api/src/__generated__";
  fi
}

validate_generated_existence() {
  arguments="$@"
  table_name="$1"
  log_dir="${PWD}/scripts/logs"
  if [ -f "$log_dir/${table_name}.txt" ]; then
    arguments=$(cat "$log_dir/${table_name}.txt")
  else
    echo ""
    echo "[API] ❌:    - Seems like you need to execute the gen_app first!"
    echo "---------------------------------------------------------------------------"
    echo "|                                                                          |"
    echo "|  gen_app  <table_name> <column_name>:<data_type>:[optional<field_type>]  |"
    echo "|                                                                          |"
    echo "---------------------------------------------------------------------------"
    exit 1
  fi

  set -- $arguments
  validate_argument "$@"
}