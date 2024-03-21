#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"

initial_table_name="$1"
model_name="$initial_table_name"
shift

file_name=$(singularize "$model_name")
pluralize_model_name=$(pluralize "$model_name")

camelized_model_name=$(snake_case_to_camelCase "$model_name")
interface_model_name=$(snake_case_to_camelCase "$file_name")

model_class_name=$(make_first_lowercase "$camelized_model_name")
pluralize_model_class_name=$(pluralize "$model_class_name")
pluralize_camelized_model_class_name=$(pluralize "$camelized_model_name")

kebabized_model_name=$(snake_case_to_kebab_case "$model_name")
route_model_name=$(pluralize "$kebabized_model_name")

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  data_type="${parts[1]}"
  model_id=$(make_model_id "$column_name")

  data_type=$(echo "$data_type" | tr '[:lower:]' '[:upper:]')
  singularize_model_name=$(singularize "${column_name}")
  camelized_reference_model_name=$(snake_case_to_camelCase "$singularize_model_name")

  if [ "$data_type" == "REFERENCES" ]
  then
    associate_file_path="${PWD}/lcnc_api/src/loaders/associate.ts"
    associate_file_content_A=$(cat "$associate_file_path")

    inject_import_model_marker="// Inject Import Model Here!"

    inject_model_A="import $camelized_model_name from '@/database/models/current/$file_name.model';"
    inject_model_B="import $camelized_reference_model_name from '@/database/models/current/$singularize_model_name.model';"
    echo "[API] 🚀: Association Insertion"

    if [[ "$associate_file_content_A" =~ $inject_import_model_marker ]]; then
      if grep -qF "$inject_model_A" "$associate_file_path"; then
        echo "[API] 🟡:    - Import Model($camelized_model_name) line already exists. No injection needed."
      else
        modified_content="${associate_file_content_A//$inject_import_model_marker/$inject_import_model_marker\n$inject_model_A}"
        echo -e "$modified_content" > "$associate_file_path"
        echo "[API] 🚀:    - Import Model($camelized_model_name) injected successfully!"
      fi
    else
      echo "[API] ❌:'$inject_import_model_marker' not found in the input file."
    fi

    associate_file_content_B=$(cat "$associate_file_path")
    if [[ "$associate_file_content_B" =~ $inject_import_model_marker ]]; then
      if grep -qF "$inject_model_B" "$associate_file_path"; then
        echo "[API] 🟡:    - Import Model($camelized_reference_model_name) line already exists. No injection needed."
      else
        modified_content="${associate_file_content_B//$inject_import_model_marker/$inject_import_model_marker\n$inject_model_B}"
        echo -e "$modified_content" > "$associate_file_path"
        echo "[API] 🚀:    - Import Model($camelized_reference_model_name) injected successfully!"
      fi
    else
      echo "[API] ❌:    - '$inject_import_model_marker' not found in the input file."
    fi

    associate_file_content=$(cat "$associate_file_path")
    association_marker="// Inject BelongsTo Model Here!"
    line_to_check_before_inject="$camelized_model_name.belongsTo($camelized_reference_model_name,"

    association_block_to_inject="$camelized_model_name.belongsTo($camelized_reference_model_name, {\n"
    association_block_to_inject+="      foreignKey: '${model_id}',\n"
    association_block_to_inject+="      targetKey: 'id',\n"
    association_block_to_inject+="      as: '$singularize_model_name'\n"
    association_block_to_inject+="    });\n"

    if [[ "$associate_file_content" =~ $association_marker ]]; then
      if grep -qF "$line_to_check_before_inject" "$associate_file_path"; then
        echo "[API] 🟡:    - Association Block already exists. No injection needed."
      else
        modified_content_comp="${associate_file_content//$association_marker/$association_marker\n    $association_block_to_inject}"
        echo -e "$modified_content_comp" > "$associate_file_path"
        echo "[API] 🚀:    - Association Block injected successfully!"
      fi
    else
      echo "[API] ❌:    - '$association_marker' not found in the input file."
    fi

    associate_file_content_ref=$(cat "$associate_file_path")
    association_marker_ref="// Inject HasMany Model Here!"
    line_to_check_before_inject_ref="$camelized_reference_model_name.hasMany($camelized_model_name,"

    ref_association_block_to_inject="$camelized_reference_model_name.hasMany($camelized_model_name, {\n"
    ref_association_block_to_inject+="      as: '$pluralize_model_name'\n"
    ref_association_block_to_inject+="    });\n"

    if [[ "$associate_file_content_ref" =~ $association_marker_ref ]]; then
      if grep -qF "$line_to_check_before_inject_ref" "$associate_file_path"; then
        echo "[API] 🟡:    - Reference Association Block already exists. No injection needed."
      else
        modified_content_comp="${associate_file_content_ref//$association_marker_ref/$association_marker_ref\n    $ref_association_block_to_inject}"
        echo -e "$modified_content_comp" > "$associate_file_path"
        echo "[API] 🚀:    - Reference Association Block injected successfully!"
      fi
    else
      echo "[API] ❌:    - '$association_marker_ref' not found in the input file."
    fi
  fi
done