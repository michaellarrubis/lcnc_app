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
import ${file_dir_name}Apis from 'src/api/modules/${api_dir_name}';
import { ${uppercased_file_name}_LIST, ${uppercased_file_name} } from './types';

export function set${pluralized_file_name}(payload) {
  return { type: ${uppercased_file_name}_LIST, payload };
}

export function set${camelized_file_name}(payload) {
  return { type: ${uppercased_file_name}, payload };
}

export function get${pluralized_file_name}() {
  return async function (dispatch) {
    const response = await ${file_dir_name}Apis.get${pluralize_camelized_file_name}Service();
    if (response?.data) {
      dispatch(set${pluralized_file_name}(response.data));
    }
  };
}

export function get${camelized_file_name}ById(id) {
  return async function (dispatch) {
    const response = await ${file_dir_name}Apis.get${camelized_file_name}ByIdService(id);
    if (response?.data) {
      dispatch(set${camelized_file_name}(response.data));
    }
  };
}

export function getFiltered${pluralized_file_name}ByParams(page, params) {
  return async function (dispatch) {
    const response = await ${file_dir_name}Apis.getFiltered${pluralize_camelized_file_name}Service(
      page,
      params
    );

    if (response?.data) {
      dispatch(set${pluralized_file_name}(response.data));
    }

    return response.data;
  };
}

export function add${camelized_file_name}() {
  return async function () {
    return await ${file_dir_name}Apis.add${camelized_file_name}Service();
  };
}

export function update${camelized_file_name}ByID(id, payload) {
  return async function () {
    return await ${file_dir_name}Apis.update${camelized_file_name}ByIdService(
      id,
      payload
    );
  };
}

export function delete${camelized_file_name}(id) {
  return async function () {
    return await ${file_dir_name}Apis.delete${camelized_file_name}ByIdService(id);
  };
}

export function deleteBulk${camelized_file_name}(ids) {
  return async function () {
    return await ${file_dir_name}Apis.deleteBulk${camelized_file_name}Service(ids);
  };
}"

module_template_dir="${PWD}/lcnc_client/src/__generated__/store/${file_dir_name}"
if [ ! -d "$module_template_dir" ]; then
  mkdir -p "$module_template_dir";
fi

module_dir="${PWD}/lcnc_client/src/store/modules/${file_dir_name}"
if [ ! -d "$module_dir" ]; then
  mkdir -p "$module_dir";
fi

echo "$not_editable_files$content" > "$module_template_dir/actions.js"

if [ ! -f "$module_dir/actions.js" ]; then
index_type_content="
// GENERATED ACTION FILE
import {
  set${pluralized_file_name},
  set${camelized_file_name},
  get${pluralized_file_name},
  get${camelized_file_name}ById,
  getFiltered${pluralized_file_name}ByParams,
  add${camelized_file_name},
  update${camelized_file_name}ByID,
  delete${camelized_file_name},
  deleteBulk${camelized_file_name}
} from 'src/__generated__/store/${file_dir_name}/actions';

// YOU MAY ADD YOUR FUNCTIONS FROM HERE!
const getCustomAction = () => {
  return async function () {
    return {};
  };
};

export {
  set${pluralized_file_name},
  set${camelized_file_name},
  get${pluralized_file_name},
  get${camelized_file_name}ById,
  getFiltered${pluralized_file_name}ByParams,
  add${camelized_file_name},
  update${camelized_file_name}ByID,
  delete${camelized_file_name},
  deleteBulk${camelized_file_name},
  getCustomAction
};"

echo "$editable_files$index_type_content" > "$module_dir/actions.js"
fi

echo "[CLIENT] 🚀:    - Action creator files generated!"