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

generatedContent="
import PropTypes from 'prop-types';
import { useCallback } from 'react';
import { useDispatch } from 'react-redux';
import { toast } from 'react-toastify';
import { CgCheckO, CgCloseO } from 'react-icons/cg';
import { MdOutlineErrorOutline } from 'react-icons/md';

import ${file_dir_name}Apis from 'src/api/modules/${api_dir_name}';
import { setIdSelection } from '@baseStores/datatable/datatableActions';

const useComponent = ({
  modal,
  formData,
  ${file_dir_name}Id,
  initialValues,

  setFormData,
  setFormValidation,

  handleModal,
  handleDeleteModal,
  handleDataAction,
  handleDataDeletion,
  handleEditModal,
  handleBulkDeleteModal
}) => {
  const dispatch = useDispatch();

  const fetch${camelized_file_name} = async id => {
    const response = await ${file_dir_name}Apis.get${camelized_file_name}ByIdService(id);
    if (response.data) {
      setFormData(prevForm => ({
        ...prevForm,
        id: response.data.id
      }));

      for (const key in initialValues) {
        setFormData(prevForm => ({
          ...prevForm,
          [key]: response.data[key]
        }));
      }
    }
  };

  const update${camelized_file_name} = async (id, payload) => {
    ${file_dir_name}Apis
      .update${camelized_file_name}ByIdService(id, payload)
      .then(response => {
        if (response.success) {
          handleDataAction({ ...response.data }, false);

          toast.success('Successfully Updated!', { icon: <CgCheckO /> });
          handleModal(null);
        }
        setFormData(formData);
      })
      .catch(err => {
        toast.error(err, { icon: <MdOutlineErrorOutline /> });
      });
  };

  const add${camelized_file_name} = async payload => {
    const response = await ${file_dir_name}Apis.add${camelized_file_name}Service(payload);
    if (response.status === 201) {
      handleDataAction({ ...response.data });

      toast.success('Successfully Added!', { icon: <CgCheckO /> });
      handleModal(null);
    }

    if (response.status === 409) {
      setFormValidation('${camelized_file_name} already exists!');
    }

    if (response.status === 400) {
      setFormValidation('Invalid data!');
    }
  };

  const delete${camelized_file_name} = async id => {
    const res = await ${file_dir_name}Apis.delete${camelized_file_name}ByIdService(id);
    if (res.success) {
      handleDataDeletion(id, []);

      toast.success('Successfully Deleted!', { icon: <CgCheckO /> });
    } else if (res.response.status === 405)
      toast.error('Unable to delete!', { icon: <CgCloseO /> });
    handleDeleteModal(modal);

    if (handleEditModal) {
      handleEditModal(null);
    }
  };

  const deleteBulk${camelized_file_name} = async ids => {
    const res = await ${file_dir_name}Apis.deleteBulk${camelized_file_name}Service(ids);
    if (res.success) {
      handleDataDeletion(null, ids, true);

      toast.success('Successfully Deleted!', { icon: <CgCheckO /> });
      handleBulkDeleteModal(modal);
      dispatch(setIdSelection([]));

      return;
    }
    if (res.response.status === 405) {
      toast.error('Unable to delete!', { icon: <CgCloseO /> });
      return;
    }

    handleBulkDeleteModal(modal);
  };

  const handleSubmit = useCallback(async () => {
    if (${file_dir_name}Id) {
      update${camelized_file_name}(${file_dir_name}Id, formData);
      return;
    }

    add${camelized_file_name}(formData);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [add${camelized_file_name}, update${camelized_file_name}]);

  return {
    handleSubmit,
    fetch${camelized_file_name},
    delete${camelized_file_name},
    deleteBulk${camelized_file_name}
  };
};

useComponent.propTypes = {
  modal: PropTypes.oneOf([PropTypes.number, PropTypes.string]),
  formData: PropTypes.arrayOf(PropTypes.object),
  ${file_dir_name}Id: PropTypes.number,
  initialValues: PropTypes.arrayOf(PropTypes.object),

  setFormData: PropTypes.func,
  setFormValidation: PropTypes.func,

  handleModal: PropTypes.func,
  handleDeleteModal: PropTypes.func,
  handleDataAction: PropTypes.func,
  handleDataDeletion: PropTypes.func,
  handleEditModal: PropTypes.func,
  handleBulkDeleteModal: PropTypes.func
};

export default useComponent;"

componentContent="
import { useState, useEffect } from 'react';
import * as Yup from 'yup';
import PropTypes from 'prop-types';

import { useBaseComponent } from 'src/hooks/base/Components/useBaseComponent';
import useGeneratedComponent from 'src/__generated__/hooks/${file_dir_name}/useComponent';

const useComponent = ({
  modal,
  handleModal,
  ${file_dir_name}Id,
  handleDataAction,
  handleDeleteModal,
  handleDataDeletion,
  handleBulkDeleteModal
}) => {
  const initialValues = {"

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"
  field_type="${parts[2]}"

  column_type=$(make_lowercase "$column_type")
  model_id=$(make_model_id "$column_name")
  data_value="''"

  if ! is_type_exists "$column_type"; then
    column_type="string"
  fi

  if ! is_field_type_exists "$field_type"; then
    field_type="input"
  fi

  if [ "$column_type" != "references" ]; then
    if [ "$column_name" != "id" ]; then

      if [ "$column_type" == "integer" ] || [ "$column_type" == "number" ]; then
        data_value="0"
      fi

      if [ "$column_type" == "boolean" ] || [ "$field_type" == "radio" ]; then
        data_value="null"
      fi

      componentContent+="
    $column_name: $data_value,"

      if [ "$arg" == "${@: -1}" ]; then
        componentContent="${componentContent%,}"
      fi
    fi
  fi

  if [ "$column_type" == "references" ]; then
    componentContent+="
    $model_id: '',"

    if [ "$arg" == "${@: -1}" ]; then
      componentContent="${componentContent%,}"
    fi
  fi
done

componentContent+="
  };

  const [formData, setFormData] = useState(initialValues);
  const [isDropdownDisplayed, setIsDropdownDisplayed] = useState(false);
  const [selectedOption, setSelectedOption] = useState('');
  const [showDeleteModal, setShowDeleteModal] = useState(null);
  const [editModal, setEditModal] = useState(null);
  const [${file_dir_name}Validation, set${camelized_file_name}Validation] = useState('');

  const {
    handleRadioChange,
    handleChange,
    handleTrimSpaces,
    handSelectChange,
    onChangeSelectHandler
  } = useBaseComponent({
    setFormData,
    setFormValidation: set${camelized_file_name}Validation,
    setSelectedOption,
    setShowDeleteModal,
    setIsDropdownDisplayed,
    setEditModal
  });

  const {
    fetch${camelized_file_name},
    handleSubmit,
    delete${camelized_file_name},
    deleteBulk${camelized_file_name}
  } = useGeneratedComponent({
    modal,
    formData,
    initialValues,
    ${file_dir_name}Id,

    setFormData,
    setFormValidation: set${camelized_file_name}Validation,

    handleModal,
    handleDataAction,
    handleDataDeletion,
    handleDeleteModal,
    handleBulkDeleteModal
  });

  useEffect(() => {
    if (${file_dir_name}Id) {
      fetch${camelized_file_name}(${file_dir_name}Id);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const validationSchema = Yup.object().shape({"

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"

  column_type=$(make_lowercase "$column_type")
  data_value="Yup.string().trim().required('Required')"
  model_id=$(make_model_id "$column_name")

  if ! is_type_exists "$column_type"; then
    column_type="string"
  fi

  if [ "$column_type" != "references" ]; then
    if [ "$column_name" != "id" ]; then

      if [ "$column_type" == "integer" ] || [ "$column_type" == "number" ]; then
      data_value="Yup.number().nullable(true).required('Required')"
      fi

      if [ "$column_type" == "boolean" ]; then
      data_value="Yup.boolean().required('Required')"
      fi

      componentContent+="
    $column_name: $data_value,"

      if [ "$arg" == "${@: -1}" ]; then
        componentContent="${componentContent%,}"
      fi
    fi
  fi

  if [ "$column_type" == "references" ]; then
    componentContent+="
      $model_id: Yup.number().nullable(true).required('Required'),"

    if [ "$arg" == "${@: -1}" ]; then
      componentContent="${componentContent%,}"
    fi
  fi
done

componentContent+="
  });

  return {
    formData,
    editModal,
    selectedOption,
    initialValues,
    handleChange,
    showDeleteModal,
    handleTrimSpaces,
    handSelectChange,
    handleRadioChange,
    handleDeleteModal,
    setIsDropdownDisplayed,
    onChangeSelectHandler,
    isDropdownDisplayed,
    validationSchema,
    ${file_dir_name}Validation,

    handleSubmit,
    fetch${camelized_file_name},
    delete${camelized_file_name},
    deleteBulk${camelized_file_name}
  };
};

useComponent.propTypes = {
  handleModal: PropTypes.func,
  ${file_dir_name}Id: PropTypes.string
};

export default useComponent;"

genereated_component_dir="${PWD}/lcnc_client/src/__generated__/hooks/${file_dir_name}"
if [ ! -d "$genereated_component_dir" ]; then
  mkdir -p "$genereated_component_dir";
fi
echo "$not_editable_files$generatedContent" > "$genereated_component_dir/useComponent.js"

component_hooks_dir="${PWD}/lcnc_client/src/hooks/${file_dir_name}"
if [ ! -d "$component_hooks_dir" ]; then
  mkdir -p "$component_hooks_dir";
fi

if [ ! -f "$component_hooks_dir/useComponent.js" ]; then
  echo "$editable_files$componentContent" > "$component_hooks_dir/useComponent.js"
fi

echo "[CLIENT] 🚀:    - Component hooks generated!"
