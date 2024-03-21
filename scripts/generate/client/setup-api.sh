#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_client/src/__generated__/api" ]; then
  mkdir -p "${PWD}/lcnc_client/src/__generated__/api"
fi

initial_file_name="$1"
file_name="$initial_file_name"
shift

kebabized_file_name=$(snake_case_to_kebab_case "$file_name")
route_file_name=$(pluralize "$kebabized_file_name")

camelized_file_name=$(snake_case_to_camelCase "$file_name")
pluralize_camelized_model_class_name=$(pluralize "$camelized_file_name")

file_dir_name=$(make_first_lowercase "$camelized_file_name")
route_dir_name=$(pluralize "$file_dir_name")

content="
import { fetchAPI } from 'src/api/fetchAPI';
import { queryParamsBuilder } from '@baseUtils';

const PATH = '$route_file_name';

export const get${pluralize_camelized_model_class_name}Service = async () => {
  try {
    return await fetchAPI({
      method: 'GET',
      endpoint: PATH
    });
  } catch (error) {
    return error;
  }
};

export const add${camelized_file_name}Service = async data => {
  try {
    return await fetchAPI({
      method: 'POST',
      endpoint: PATH,
      body: data
    });
  } catch (error) {
    return error.response;
  }
};

export const getFiltered${pluralize_camelized_model_class_name}Service = async (page, searchParams) => {
  try {
    return await fetchAPI({
      method: 'GET',
      endpoint: queryParamsBuilder(PATH, page, searchParams)
    });
  } catch (error) {
    return error;
  }
};

export const get${camelized_file_name}ByIdService = async id => {
  try {
    return await fetchAPI({
      method: 'GET',
      endpoint: \`\${PATH}/\${id}\`
    });
  } catch (error) {
    return error;
  }
};

export const delete${camelized_file_name}ByIdService = async id => {
  try {
    return await fetchAPI({
      method: 'DELETE',
      endpoint: \`\${PATH}/\${id}\`
    });
  } catch (error) {
    return error;
  }
};

export const update${camelized_file_name}ByIdService = async (id, data) => {
  const payload = data;
  if (payload?.id) {
    delete payload.id;
    delete payload.created_by;
    delete payload.updated_by;
    delete payload.created_at;
    delete payload.updated_at;
  }

  try {
    return await fetchAPI({
      method: 'PUT',
      endpoint: \`\${PATH}/\${id}\`,
      body: payload
    });
  } catch (error) {
    return error;
  }
};

export const deleteBulk${camelized_file_name}Service = async ids => {
  try {
    return await fetchAPI({
      method: 'DELETE',
      endpoint: \`\${PATH}/bulk-delete\`,
      body: { ids }
    });
  } catch (error) {
    return error.response;
  }
};"

echo "$not_editable_files$content" > "${PWD}/lcnc_client/src/__generated__/api/${route_dir_name}.js"

if [ ! -f "${PWD}/lcnc_client/src/api/modules/${route_dir_name}.js" ]; then
route_content="
// GENERATED API FUNCTIONS
import * as $route_dir_name from 'src/__generated__/api/${route_dir_name}';

// YOU MAY ADD YOUR FUNCTIONS FROM HERE!
import { fetchAPI } from 'src/api/fetchAPI';

const customApifunction = async () => {
  try {
    return await fetchAPI({
      method: 'GET',
      endpoint: ${route_dir_name}.PATH
    });
  } catch (error) {
    return error;
  }
};

export default {
  ...${route_dir_name},
  customApifunction
};"

echo "$editable_files$route_content" > "${PWD}/lcnc_client/src/api/modules/${route_dir_name}.js"
fi

echo "[CLIENT] 🚀: API routes generated!"
