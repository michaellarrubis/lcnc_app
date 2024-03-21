#!/bin/bash

source "${PWD}/scripts/utils/helpers.sh"

if [ "$#" -eq 0 ]; then
  echo "[CLIENT]: Please provide the target file_name!"
  exit 1
fi

initial_file_name="$1"
if ! to_snake_case "$initial_file_name"; then
  echo "[CLIENT] ❌: The $initial_file_name must be in a snake_case."
  exit 1
fi

file_name="$initial_file_name"
shift

uppercased_file_name=$(make_uppercase "$file_name")
file_dir_name=$(make_first_lowercase "$(snake_case_to_camelCase "$file_name")")

content="
export const ${uppercased_file_name} = '${uppercased_file_name}';
export const ${uppercased_file_name}_LIST = '${uppercased_file_name}_LIST';"

module_template_dir="${PWD}/lcnc_client/src/__generated__/store/${file_dir_name}"
if [ ! -d "$module_template_dir" ]; then
  mkdir -p "$module_template_dir";
fi

module_dir="${PWD}/lcnc_client/src/store/modules/${file_dir_name}"
if [ ! -d "$module_dir" ]; then
  mkdir -p "$module_dir";
fi

echo "$not_editable_files$content" > "$module_template_dir/types.js"

if [ ! -f "$module_dir/types.js" ]; then
index_type_content="
// GENERATED TYPES FILE
import * as ${file_dir_name}TemplateTypes from 'src/__generated__/store/${file_dir_name}/types';

// YOU MAY ADD YOUR FUNCTIONS FROM HERE!
const GET_LIST = 'GET_LIST';

export default {
  ...${file_dir_name}TemplateTypes,
  GET_LIST
};"

echo "$editable_files$index_type_content" > "$module_dir/types.js"
fi

echo "[CLIENT] 🚀:    - Redux type files generated!"