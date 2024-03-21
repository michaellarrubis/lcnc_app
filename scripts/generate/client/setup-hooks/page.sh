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
import { useState, useEffect, useCallback, useMemo } from 'react';
import { useSelector } from 'react-redux';
import { useLocation } from 'react-router-dom';

import { setOverflowStyle } from '@baseUtils';
import useBasePage from 'src/hooks/base/Pages/useBasePage';

const usePage = ({
  form,
  page,
  setPage,
  hasMore,
  setHasMore,
  ${file_dir_name}List,
  fetchData
}) => {
  const location = useLocation();
  const { total_items, total_pages } = useSelector(state => state.${file_dir_name});

  const [showModal, setShowModal] = useState(null);
  const [showViewModal, setShowViewModal] = useState(null);
  const [showDeleteModal, setShowDeleteModal] = useState(null);
  const [${file_dir_name}Id, set${camelized_file_name}Id] = useState(null);

  const { showBulkDeleteModal, handleBulkDeleteModal, pushQuery } =
    useBasePage();

  const resetToDefault = () => {
    setPage(1);
    localStorage.setItem('lcnc-${file_name}-page-no', '1');
    setHasMore(true);
  };

  const ${file_dir_name}ListMemo = useMemo(() => {
    return ${file_dir_name}List ?? [];
  }, [${file_dir_name}List]);

  const submitFilter = form.handleSubmit(params => {
    resetToDefault();
    pushQuery(params, 'lcnc-${file_name}-params');
  });

  const handleModal = useCallback(
    (modal, id = null) => {
      setShowModal(modal);
      set${camelized_file_name}Id(modal ? id : null);

      // disable scroll when modal is shown
      setOverflowStyle(modal);

      setHasMore(false);
    },
    [setShowModal, set${camelized_file_name}Id]
  );

  const handleViewModal = useCallback(
    (modal, id = null) => {
      setShowViewModal(modal);
      set${camelized_file_name}Id(modal ? id : null);

      // disable scroll when modal is shown
      setOverflowStyle(modal);

      setHasMore(false);
    },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [setShowModal, set${camelized_file_name}Id]
  );

  const handleDeleteModal = useCallback(
    ({ modal, id }) => {
      setShowDeleteModal(modal);
      set${camelized_file_name}Id(modal ? id : null);

      // disable scroll when modal is shown
      setOverflowStyle(modal);

      setHasMore(false);
    },
    [setShowDeleteModal, set${camelized_file_name}Id]
  );

  const handleDataAction = useCallback(
    (payload, isNew = true) => {
      setHasMore(false);

      resetToDefault();
      fetchData();
    },
    [fetchData]
  );

  const handleDataDeletion = useCallback(
    (id, ids, isBulk = false) => {
      setHasMore(false);

      if (isBulk && ids.length > 0) {
        ids.forEach(idItem => {
          const ${file_name} = ${file_dir_name}List.findIndex(item => item.id === idItem);
          ${file_dir_name}List.splice(${file_name}, 1);
        });
        return;
      }

      const ${file_name} = ${file_dir_name}List.findIndex(item => item.id === id);
      ${file_dir_name}List.splice(${file_name}, 1);
    },
    [${file_dir_name}List]
  );

  useEffect(() => {
    resetToDefault();

    const savedSearchParams = localStorage.getItem(
      'lcnc-${file_name}-params'
    );
    const parsedSearchParams = new URLSearchParams(savedSearchParams);

    if (savedSearchParams) {
      form.reset(Object.fromEntries(parsedSearchParams));
      fetchData();
    } else {
      // set default status
      form.reset({});
    }

    pushQuery({}, 'lcnc-${file_name}-params');
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    resetToDefault();

    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [location.search]);

  useEffect(() => {
    localStorage.setItem('lcnc-${file_name}-page-no', JSON.stringify(page));
  }, [page]);

  useEffect(() => {
    if (total_items > 10 && ${file_dir_name}List.length === 10) {
      fetchData();
    }

    if (total_pages <= 2) setHasMore(false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [${file_dir_name}List]);

  return {
    page,
    hasMore,
    setPage,
    setHasMore,
    ${file_dir_name}Id,

    showModal,
    showViewModal,
    showDeleteModal,
    showBulkDeleteModal,

    handleModal,
    submitFilter,
    ${file_dir_name}ListMemo,

    handleBulkDeleteModal,
    handleViewModal,
    handleDeleteModal,
    handleDataAction,
    handleDataDeletion
  };
};

export default usePage;"

content="
import { useState, useCallback } from 'react';
import { toast } from 'react-toastify';
import { useForm } from 'react-hook-form';
import { useDispatch } from 'react-redux';

import * as ${api_dir_name}Actions from 'src/store/modules/${file_dir_name}/actions';
import useGeneratedPage from 'src/__generated__/hooks/${file_dir_name}/usePage';

const usePage = () => {
  const dispatch = useDispatch();
  const form = useForm({ defaultValues: {} });

  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  const [${file_dir_name}List, set${camelized_file_name}List] = useState([]);

  const ${file_dir_name}Columns = [
    { key: 'id', label: 'ID' },"

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"
  model_id=$(make_model_id "$column_name")

  column_type=$(make_lowercase "$column_type")
  sequelize_type="DataTypes.$column_type"
  title_cased_column_name=$(snake_case_to_title_case "$column_name")

  if ! is_type_exists "$column_type"; then
    column_type="string"
  fi

  if [ "$column_type" != "references" ]; then
    if [ "$column_name" != "id" ]; then
      content+="
    { key: '$column_name', label: '$(singularize "$title_cased_column_name")' },"

      if [ "$arg" == "${@: -1}" ]; then
        content="${content%,}"
      fi
    fi
  fi

  if [ "$column_type" == "references" ]; then
    content+="
    { key: '$model_id', label: '$(singularize "$title_cased_column_name")' },"

    if [ "$arg" == "${@: -1}" ]; then
      content="${content%,}"
    fi
  fi
done

content+="
  ];

  const fetchData = useCallback(async () => {
    try {
      const savedSearchParams = localStorage.getItem(
        'lcnc-${file_name}-params'
      );
      const savedPage = parseInt(
        localStorage.getItem('lcnc-${file_name}-page-no'),
        10
      );

      let params = '';
      if (savedSearchParams) {
        params = new URLSearchParams(savedSearchParams);
      }

      const data = await dispatch(
        ${api_dir_name}Actions.getFiltered${pluralized_file_name}ByParams(savedPage, params)
      );

      let mappedDataList = [];
      if (data.items.length > 0) {
        mappedDataList = data.items.map(item => {
          return {
            id: item.id,"

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"

  column_type=$(make_lowercase "$column_type")
  model_id=$(make_model_id "$column_name")

  if ! is_type_exists "$column_type"; then
    column_type="string"
  fi

  if [ "$column_type" != "references" ]; then
    if [ "$column_name" != "id" ]; then
      column_value="item.$column_name ?? '',"

      if [ "$column_type" == "boolean" ]; then
        column_value="item.$column_name ?? null,"
      fi

      if [ "$column_type" == "integer" ] || [ "$column_type" == "number" ]; then
        column_value="item.$column_name ?? 0,"
      fi

      content+="
            $column_name: $column_value"

      if [ "$arg" == "${@: -1}" ]; then
        content="${content%,}"
      fi
    fi
  fi

  if [ "$column_type" == "references" ]; then
    content+="
            $model_id: item.$model_id ?? '',"

    if [ "$arg" == "${@: -1}" ]; then
      content="${content%,}"
    fi
  fi
done

content+="
          };
        });
      }

      const updatedList =
        Number(savedPage) !== 1
          ? ${file_dir_name}List.concat(mappedDataList)
          : mappedDataList;
      set${camelized_file_name}List(updatedList);

      if (data.current_page >= data.total_pages) {
        setHasMore(false);
      } else {
        setHasMore(true);
        setPage(savedPage + 1);
      }
    } catch (error) {
      toast.error(\`Error fetching data: ${error}\`);
    }
  }, [dispatch, ${file_dir_name}List]);

  const generatedPageHooks = useGeneratedPage({
    form,
    page,
    setPage,
    hasMore,
    setHasMore,
    ${file_dir_name}List,
    fetchData
  });

  return {
    form,
    fetchData,
    ${file_dir_name}List,
    ${file_dir_name}Columns,
    ...generatedPageHooks
  };
};

export default usePage;"

generated_page_hooks_dir="${PWD}/lcnc_client/src/__generated__/hooks/${file_dir_name}"
if [ ! -d "$generated_page_hooks_dir" ]; then
  mkdir -p "$generated_page_hooks_dir";
fi
echo "$not_editable_files$generatedContent" > "$generated_page_hooks_dir/usePage.js"

page_hooks_dir="${PWD}/lcnc_client/src/hooks/${file_dir_name}"
if [ ! -d "$page_hooks_dir" ]; then
  mkdir -p "$page_hooks_dir";
fi

if [ ! -f "$page_hooks_dir/usePage.js" ]; then
  echo "$editable_files$content" > "$page_hooks_dir/usePage.js"
fi

echo "[CLIENT] 🚀:    - Page hooks generated!"
