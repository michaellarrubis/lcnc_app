#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_api/src/__generated__/interfaces" ]; then
  mkdir -p "${PWD}/lcnc_api/src/__generated__/interfaces";
fi

initial_table_name="$1"
initialized_table_name="$initial_table_name"
shift

file_name=$(singularize "${initialized_table_name}")
camelized_model_name=$(snake_case_to_camelCase "$file_name")

echo "[API] 🚀: Interface"
generated_lines=""

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"

  model_id=$(make_model_id "$column_name")
  column_type=$(make_lowercase "$column_type")

  if ! is_type_exists "$column_type"; then
    column_type="string"
  fi

  if [ "$column_type" == "references" ]; then
    generated_lines+="
  $model_id: number;"
  fi

  if [ "$column_type" != "references" ]; then
    if [ "$column_type" == "integer" ]; then
      column_type="number"
    fi

    if [ "$column_type" == "text" ]; then
      column_type="string"
    fi

    if [ "$column_name" != "id" ]; then
      generated_lines+="
  $column_name: $column_type;"
    fi
  fi
done

generatedInterface="
export interface I${camelized_model_name}Main {
  id: number;$generated_lines
}

export interface I$camelized_model_name extends I${camelized_model_name}Main {
  status: string;
  created_by: number;
  updated_by: number;
  created_at: string;
  updated_at: string;
}

export interface I${camelized_model_name}Input {
  id?: number;$generated_lines
}

export interface I${camelized_model_name}Payload {
  search: string; 
  page: number;
  limit: number;
  all: boolean;
}

export interface I${camelized_model_name}Results {
  total_items: number;
  items: I${camelized_model_name}[];
  current_page: number;
  total_pages: number;
}

export interface I${camelized_model_name}ResponsePayload {
  count: number;
  rows: I${camelized_model_name}[];
  page: number;
}
"

if [ ! -f "${PWD}/lcnc_api/src/__generated__/interfaces/${file_name}.ts" ]; then
  echo "[API] 🚀:    - Interface file generated!"
else
  echo "[API] 🚀:    - Interface file re-generated!"
fi

echo "$not_editable_files$generatedInterface" > "${PWD}/lcnc_api/src/__generated__/interfaces/${file_name}.ts"


if [ ! -f "${PWD}/lcnc_api/src/ts/interfaces/${file_name}.ts" ]; then
  output="
import {
  I${camelized_model_name},
  I${camelized_model_name}Main,
  I${camelized_model_name}Input,
  I${camelized_model_name}Payload,
  I${camelized_model_name}Results,
  I${camelized_model_name}ResponsePayload
} from '@/__generated__/interfaces/${file_name}';

// YOU MAY ADD YOUR CUSTOM INTERFACES HERE THEN EXPORT IT!

export {
  I${camelized_model_name},
  I${camelized_model_name}Main,
  I${camelized_model_name}Input,
  I${camelized_model_name}Payload,
  I${camelized_model_name}Results,
  I${camelized_model_name}ResponsePayload
};"

  echo "$editable_files$output" > "${PWD}/lcnc_api/src/ts/interfaces/${file_name}.ts"
  echo "[API] 🚀:    - Interface editable file generated!"
fi

file_path="${PWD}/lcnc_api/src/ts/types/express/index.d.ts"

inject_interface_marker="// Inject Model Interfaces here!"
interface_to_inject="import { I${camelized_model_name} } from '@/ts/interfaces/${file_name}';"

file_content=$(cat "$file_path")
if [[ "$file_content" =~ $inject_interface_marker ]]; then
  if grep -qF "$interface_to_inject" "$file_path"; then
    echo "[API] 🟡:    - Model Interface Line already injected!"
  else
    modified_content="${file_content//$inject_interface_marker/$inject_interface_marker\n$interface_to_inject}"
    echo -e "$modified_content" > "$file_path"
    echo "[API] 🚀:    - Model Interface Line injected!"
  fi
else
  echo "[API] ❌:    - '$inject_interface_marker' not found in the input file."
fi

inject_model_marker="// Inject Current Models Here!"
model_to_inject="    export type ${camelized_model_name}Model = Model<I${camelized_model_name}>;"

file_content=$(cat "$file_path")
if [[ "$file_content" =~ $inject_model_marker ]]; then
  if grep -qF "$model_to_inject" "$file_path"; then
    echo "[API] 🟡:    - Model Line already injected!"
  else
    modified_content="${file_content//$inject_model_marker/$inject_model_marker\n$model_to_inject}"
    echo -e "$modified_content" > "$file_path"
    echo "[API] 🚀:    - Model Line injected!"
  fi
else
  echo "[API] ❌:    - '$inject_model_marker' not found in the input file."
fi