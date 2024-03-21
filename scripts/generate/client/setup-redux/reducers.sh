#!/bin/bash

source "${PWD}/scripts/utils/helpers.sh"

if [ "$#" -eq 0 ]; then
  echo "[CLIENT]: Please provide the target file_name!"
  exit 1
fi

initial_file_name="$1"
if ! to_snake_case "$initial_file_name"; then
  echo "[CLIENT] ❌: The file_name must be in a snake_case."
  exit 1
fi

file_name="$initial_file_name"
shift

uppercased_file_name=$(make_uppercase "$file_name")
camelized_file_name=$(snake_case_to_camelCase "$file_name")
pluralize_camelized_file_name=$(pluralize "$camelized_file_name")

pluralized_file_name=$(pluralize "$(snake_case_to_camelCase "$file_name")")
file_dir_name=$(make_first_lowercase "$(snake_case_to_camelCase "$file_name")")
api_dir_name=$(pluralize "$file_dir_name")

content="
import { getFilteredList } from 'src/utils/base';
import { ${uppercased_file_name}_LIST, ${uppercased_file_name} } from './types';

export const TEMPLATE_INITIAL_STATE = {
  items: [],
  item: {},
  current_page: 0,
  total_pages: 1,
  total_items: 0
};

export const TEMPLATE_CASE_TYPE = (type, state, payload) => {
  let state_return = state;

  switch (type) {
    case ${uppercased_file_name}_LIST:
      state_return = {
        ...state,
        items: getFilteredList(state.items.concat(payload.items), 'id'),
        current_page: payload.current_page ?? 0,
        total_pages: payload.total_pages ?? 1,
        total_items: payload.total_items ?? 0
      };
      break;
    case ${uppercased_file_name}:
      state_return = {
        ...state,
        item: payload
      };
      break;
    default:
      state_return = state;
  }

  return state_return;
};"

module_template_dir="${PWD}/lcnc_client/src/__generated__/store/${file_dir_name}"
if [ ! -d "$module_template_dir" ]; then
  mkdir -p "$module_template_dir";
fi

module_dir="${PWD}/lcnc_client/src/store/modules/${file_dir_name}"
if [ ! -d "$module_dir" ]; then
  mkdir -p "$module_dir";
fi

echo "$not_editable_files$content" > "$module_template_dir/reducers.js"
echo "[CLIENT] 🚀:    - Reducer file generated!"

if [ ! -f "$module_dir/reducers.js" ]; then
index_type_content="
// GENERATED REDUCER FILE
import {
  TEMPLATE_CASE_TYPE,
  TEMPLATE_INITIAL_STATE
} from 'src/__generated__/store/${file_dir_name}/reducers';

// YOU MAY ADD YOUR FUNCTIONS FROM HERE!
const INITIAL_STATE = {
  ...TEMPLATE_INITIAL_STATE, // DO NOT REMOVE THIS LINE!
  custom: null
};

export default function ${file_dir_name}Reducers(
  state = INITIAL_STATE,
  { type, payload } = {}
) {
  switch (type) {
    case 'CUSTOM_${uppercased_file_name}':
      return {
        ...state,
        custom: payload
      };
    default:
      return TEMPLATE_CASE_TYPE(type, state, payload); // DO NOT REMOVE THIS LINE!
  }
}"

echo "$editable_files$index_type_content" > "$module_dir/reducers.js"
fi

# Define the marker
file_path="${PWD}/lcnc_client/src/store/modules/index.js"

inject_import_reducer="// Inject imported reducers here!"
interface_to_inject="import ${file_dir_name}Reducers from './${file_dir_name}/reducers';"

file_content=$(cat "$file_path")
if [[ "$file_content" =~ $inject_import_reducer ]]; then
  if grep -qF "$interface_to_inject" "$file_path"; then
    echo "[CLIENT] 🟡:      - Reducer import line already injected!"
  else
    modified_content="${file_content//$inject_import_reducer/$inject_import_reducer\n$interface_to_inject}"
    echo -e "$modified_content" > "$file_path"
    echo "[CLIENT] 🚀:      - Reducer import line injected!"
  fi
else
  echo "[CLIENT] ❌:      '$inject_import_reducer' not found in the input file."
fi

inject_instantiated_reducer="// Inject reducers here!"
model_to_inject="  ${file_dir_name}: ${file_dir_name}Reducers,"

file_content=$(cat "$file_path")
if [[ "$file_content" =~ $inject_instantiated_reducer ]]; then
  if grep -qF "$model_to_inject" "$file_path"; then
    echo "[CLIENT] 🟡:      - Reducer initialization line already injected!"
  else
    modified_content="${file_content//$inject_instantiated_reducer/$inject_instantiated_reducer\n$model_to_inject}"
    echo -e "$modified_content" > "$file_path"
    echo "[CLIENT] 🚀:      - Reducer initializaion line injected!"
  fi
else
  echo "[CLIENT] ❌:      '$inject_instantiated_reducer' not found in the input file."
fi


store_file_path="${PWD}/lcnc_client/src/store/index.js"

inject_blacklist_reducer_marker="// Inject reducer to be excluded!"
reducer_to_inject="   '${file_dir_name}',"
store_file_content=$(cat "$store_file_path")
if [[ "$store_file_content" =~ $inject_blacklist_reducer_marker ]]; then
  if grep -qF "$reducer_to_inject" "$store_file_path"; then
    echo "[CLIENT] 🟡:      - Reducer to be blacklisted line already injected!"
  else
    modified_content="${store_file_content//$inject_blacklist_reducer_marker/$inject_blacklist_reducer_marker\n$reducer_to_inject}"
    echo -e "$modified_content" > "$store_file_path"
    echo "[CLIENT] 🚀:      - Reducer to be blacklisted line injected!"
  fi
else
  echo "[CLIENT] ❌:      '$inject_blacklist_reducer_marker' not found in the input file."
fi