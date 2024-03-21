#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


initial_file_name="$1"
file_name="$initial_file_name"
shift

uppercased_file_name=$(make_uppercase "$file_name")
camelized_file_name=$(snake_case_to_camelCase "$file_name")
pluralize_camelized_file_name=$(pluralize "$camelized_file_name")

pluralized_file_name=$(pluralize "$(snake_case_to_camelCase "$file_name")")
file_dir_name=$(make_first_lowercase "$(snake_case_to_camelCase "$file_name")")
api_dir_name=$(pluralize "$file_dir_name")
title_file_name=$(snake_case_to_title_case "$file_name")
kebabize_file_name=$(snake_case_to_kebab_case "$file_name")

content="
/* eslint-disable jsx-a11y/label-has-associated-control */
import React from 'react';
import PropTypes from 'prop-types';
import { Formik, Form } from 'formik';
import {
  FormField,
  FormCard,
  FormGridCard,
  Text
} from '@baseComponents/Common';

import useComponent from 'src/hooks/${file_dir_name}/useComponent';

const AddEditModal = ({
  dataList,
  handleModal,
  ${file_dir_name}Id,
  handleDataAction
}) => {
  const {
    formData,
    initialValues,
    validationSchema,
    ${file_dir_name}Validation,

    handleChange,
    handleSubmit,
    handleTrimSpaces,
    onChangeSelectHandler
  } = useComponent({
    dataList,
    handleModal,
    ${file_dir_name}Id,
    handleDataAction,
    editModal: handleModal
  });

  return (
    <Formik
      enableReinitialize
      validateOnMount
      initialValues={initialValues}
      validationSchema={validationSchema}
      onSubmit={handleSubmit}
      validateOnBlur={false}
      validateOnChange={false}
    >
      {({
        errors,
        touched,
        setFieldValue,
        setFieldTouched,
        isSubmitting,
        setFieldError,
        setErrors
      }) => {
        if (formData.id) {
          const fieldErrors = errors;

          for (const key in formData) {
            if (formData[key]) delete fieldErrors[key];
          }

          setErrors(fieldErrors);
        }

        return (
          <Form id=\"${camelized_file_name}Form\">
            <div className=\"flex justify-between items-center w-auto mx-[35px] border-solid border-b-[1px] border-[#eaeaea] pb-[20px]\">
              <h4 className=\"text-[22px] font-stolzlMedium leading-[27px]\">
                {${file_dir_name}Id ? 'Edit' : 'Add'} ${title_file_name}
              </h4>
              <div className=\"flex\">
                <div className=\"text-right mr-[10px]\">
                  <button
                    type=\"submit\"
                    className=\"text-[12px] text-white leading-[100%] bg-gray-400 hover:bg-gray-500 border-none p-[14px_41px] rounded\"
                    disabled={isSubmitting}
                  >
                    <span className=\"relative before:content-[''] before:block before:w-3 before:h-3 before:bg-[url('/src/assets/base/icons/save.svg')] before:bg-no-repeat before:bg-center before:absolute before:top-[50%] before:left-0 before:translate-y-[-50%] before:translate-x-0 pl-[18px]\">
                      Save
                    </span>
                  </button>
                </div>
              </div>
            </div>

            <div className=\"mx-[35px] mt-[20px] mb-[30px] w-auto\">
              <Text tag=\"error\" markup={${file_dir_name}Validation} />
            </div>

            <div className=\"w-full\">
              <div className=\"px-[35px] mt-5\">
                <FormGridCard cols=\"2\">"

for arg in "$@"; do
IFS=':' read -ra parts <<< "$arg"
column_name="${parts[0]}"
column_type="${parts[1]}"
field_type="${parts[2]}"
field_type_value="text"

camelized_column_name=$(snake_case_to_camelCase "$column_name")
title_column_name=$(snake_case_to_title_case "$column_name")
singularize_model_name=$(singularize "$title_column_name")

column_type=$(make_lowercase "$column_type")
data_value="formData.${column_name} ?? ''"
model_id=$(make_model_id "$column_name")

if ! is_type_exists "$column_type"; then
  column_type="string"
fi

if ! is_field_type_exists "$field_type"; then
  field_type="input"
  field_type_value="text"
fi

if [ "$column_type" == "integer" ] || [ "$column_type" == "number" ]; then
  field_type_value="number"
  data_value="Number(formData.${column_name}) ?? 0"
fi

if [[ $column_name = *'email'* ]]; then
  field_type_value="email"
fi

if [ "$column_type" == "string" ]; then
  field_type_value="text"
fi

if [ "$column_type" == "text" ]; then
  field_type_value="textarea"
fi

if [ "$column_type" == "references" ]; then
  field_type_value="number"
  data_value="formData.$model_id"
fi

if [ "$column_name" != "id" ]; then
  if [ "$field_type" != "select" ] && [ "$field_type" != "radio" ] && [ "$field_type" == "input" ] && [ "$column_type" != "boolean" ]; then
    if [ "$column_type" == "references" ]; then
      column_name=$(make_model_id "$column_name")
    fi

    content+="
                  <FormCard>
                    <FormField
                      label=\"${singularize_model_name}\"
                      required
                      name=\"${column_name}\"
                      type=\"${field_type_value}\"
                      placeholder=\"\"
                      errorMessage=\"Field Required\"
                      value={$data_value}
                      error={errors.${column_name} && touched.${column_name}}
                      onBlur={handleTrimSpaces}
                      onChange={e =>
                        handleChange(
                          e,
                          setFieldValue,
                          setFieldTouched,
                          setFieldError
                        )
                      }
                    />
                    {errors.${column_name} && touched.${column_name} && (
                      <div className=\"text-[10px] mt-1 font-stolzlBook text-[#E43B26]\">
                        {errors.${column_name}}
                      </div>
                    )}
                  </FormCard>"
  fi

  if [ "$field_type" == "select" ]; then
    if [ "$column_type" == "references" ]; then
      column_name=$(make_model_id "$column_name")
    fi

    content+="
                  <FormCard>
                    <FormField
                      label=\"${singularize_model_name}\"
                      type=\"select\"
                      errorMessage=\"Field Required\"
                      required
                      error={errors.${column_name} && touched.${column_name}}
                      placeholder=\"Select Value\"
                      options={[{ id: 1, label: 'Item 1', value: 'value-1' }]}
                      selectname=\"${column_name}\"
                      currentValue={$data_value}
                      onChangeValue={value =>
                        onChangeSelectHandler(
                          value,
                          '${column_name}',
                          setFieldValue,
                          setFieldTouched,
                          setFieldError
                        )
                      }
                    />
                    {errors.${column_name} && touched.${column_name} && (
                      <div className=\"text-[10px] mt-1 font-stolzlBook text-[#E43B26]\">
                        {errors.${column_name}}
                      </div>
                    )}
                  </FormCard>"
  fi

  if [ "$field_type" == "radio" ] || [ "$column_type" == "boolean" ]; then
    if [ "$column_type" == "references" ]; then
      column_name=$(make_model_id "$column_name")
    fi

    optionsValue="[
                      { label: 'Option 1', value: 'value-1' },
                      { label: 'Option 2', value: 'value-2' }
                    ]"

    if [ "$column_type" == "integer" ]; then
      optionsValue="[
                        { label: 'Value 1', value: 1 },
                        { label: 'Value 2', value: 2 }
                      ]"
    fi

    if [ "$column_type" == "boolean" ]; then
      optionsValue="[
                        { label: 'True', value: true },
                        { label: 'False', value: false }
                      ]"
    fi

    content+="
                  <FormCard>
                    <FormField
                      label=\"${singularize_model_name}\"
                      type=\"radio\"
                      required
                      options={$optionsValue}
                      name=\"${column_name}\"
                      value={$data_value}
                      onChange={e =>
                        handleChange(
                          e,
                          setFieldValue,
                          setFieldTouched,
                          setFieldError
                        )
                      }
                    />
                    {errors.${column_name} && touched.${column_name} && (
                      <div className=\"text-[10px] mt-1 font-stolzlBook text-[#E43B26]\">
                        {errors.${column_name}}
                      </div>
                    )}
                  </FormCard>"
  fi
fi
done

content+="
                </FormGridCard>
              </div>
            </div>
          </Form>
        );
      }}
    </Formik>
  );
};

AddEditModal.propTypes = {
  handleModal: PropTypes.func,
  ${file_dir_name}Id: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  dataList: PropTypes.array
};

export default AddEditModal;"

page_dir="${PWD}/lcnc_client/src/pages/${file_dir_name}"

if [ ! -d "$page_dir" ]; then
  mkdir -p "$page_dir";
fi

if [ ! -f "$page_dir/AddEditModal.jsx" ]; then
  echo "$editable_files$content" > "$page_dir/AddEditModal.jsx"
  echo "[CLIENT] 🚀:    - Add Edit modal component generated!"
else
  echo "[CLIENT] 🚀:    - Add Edit modal component already generated!"
fi
