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
pluralize_title_file_name=$(pluralize "$title_file_name")
pluralize_kebabed_file_name=$(pluralize "$kebabize_file_name")

content="
import React from 'react';
import PropTypes from 'prop-types';
import { useSelector } from 'react-redux';
import InfiniteScroll from 'react-infinite-scroll-component';
import { useUserAccess } from '@baseHooks/useUserAccess';
import { getCustomMenuCode } from 'src/utils/base';

import usePage from 'src/hooks/${file_dir_name}/usePage';
import useComponent from 'src/hooks/${file_dir_name}/useComponent';

import { SlideModal, ModalCenter, Breadcrumbs } from '@baseComponents/Common';
import Filter from '@baseComponents/Common/Filter/Filter';
import Datatable from '@baseComponents/Common/Datatable';
import DeleteModalUI from '@baseComponents/Common/DeleteModalUI';

import AddEditModal from './AddEditModal';

const Index = ({ menuCode: code }) => {
  const menuCode = getCustomMenuCode(code);

  const { menus } = useUserAccess();
  const { ids: idsToDelete } = useSelector(state => state.datatable);
  const {
    form,
    hasMore,
    ${file_dir_name}Id,

    fetchData,
    showModal,
    handleModal,
    submitFilter,
    showDeleteModal,
    ${file_dir_name}List,
    ${file_dir_name}ListMemo,
    ${file_dir_name}Columns,
    handleDeleteModal,
    handleBulkDeleteModal,
    showBulkDeleteModal,
    handleDataAction,
    handleDataDeletion
  } = usePage();
  const { delete${camelized_file_name}, deleteBulk${camelized_file_name} } = useComponent({
    handleBulkDeleteModal,
    handleDeleteModal,
    id: ${file_dir_name}Id,
    modal: showDeleteModal,
    handleDataDeletion
  });

  return (
    <div className=\"comp__container\">
      <Breadcrumbs crumbs={[{ name: '${title_file_name}', link: '/${kebabize_file_name}' }]} />

      <div className=\"mt-5\">
        <div className=\"filter__content--search overflow-auto\">
          <Filter
            searchInputPlaceholder=\"Search\"
            buttonName=\"${camelized_file_name}\"
            buttonLink={false}
            buttonOnClick={() => handleModal('AddEdit')}
            bulkDeleteClick={() => handleBulkDeleteModal('BulkDeleteModal')}
            form={form}
            submitFilter={submitFilter}
            menuCode={menuCode}
          />
          <InfiniteScroll
            dataLength={${file_dir_name}ListMemo?.length}
            next={fetchData}
            hasMore={hasMore}
            loader={<h4 className=\"text-center mt-5\">Loading...</h4>}
            endMessage={
              <p className=\"text-center mt-5\">
                {!${file_dir_name}ListMemo.length && (
                  <span className=\"text-gray-50\">No records found.</span>
                )}
              </p>
            }
          >
            <Datatable
              shouldDisplayEditable={false}
              datasource={${file_dir_name}ListMemo || []}
              clickableRows={false}
              headingColumns={${file_dir_name}Columns}
              title=\"${camelized_file_name}\"
              actions={['edit', 'delete']}
              showModal={showModal}
              handleModal={handleModal}
              handleDeleteModal={handleDeleteModal}
              modalName=\"AddEdit\"
              deleteModal=\"DeleteModal\"
              shouldEllipsis
              access={menus[menuCode]?.user_group_access}
              onExport={false}
              isExport={false}
              isCostCenter
              codeField=\"id\"
            />
          </InfiniteScroll>
        </div>
      </div>
      <SlideModal
        showModal={showModal}
        modalName=\"AddEdit\"
        handleModal={handleModal}
      >
        {showModal && (
          <AddEditModal
            handleDataAction={handleDataAction}
            handleModal={handleModal}
            ${file_dir_name}Id={${file_dir_name}Id}
            dataList={${file_dir_name}List}
          />
        )}
      </SlideModal>
      <ModalCenter showModal={showDeleteModal} modalName=\"DeleteModal\">
        {showDeleteModal && (
          <DeleteModalUI
            submit={() => delete${camelized_file_name}(${file_dir_name}Id)}
            cancel={() => handleDeleteModal(showDeleteModal)}
          />
        )}
      </ModalCenter>
      <ModalCenter showModal={showBulkDeleteModal} modalName=\"BulkDeleteModal\">
        {showBulkDeleteModal && (
          <DeleteModalUI
            submit={() => deleteBulk${camelized_file_name}(idsToDelete)}
            cancel={() => handleBulkDeleteModal(null)}
          />
        )}
      </ModalCenter>
    </div>
  );
};

Index.propTypes = {
  menuCode: PropTypes.string
};

export default Index;"

page_dir="${PWD}/lcnc_client/src/pages/${file_dir_name}"

if [ ! -d "$page_dir" ]; then
  mkdir -p "$page_dir";
fi

if [ ! -f "$page_dir/Index.jsx" ]; then
  echo "$editable_files$content" > "$page_dir/Index.jsx"
  echo "[CLIENT] 🚀:    - Page generated!"
else
  echo "[CLIENT] 🚀:    - Page already generated!"
fi

router_file_path="${PWD}/lcnc_client/src/Routers.jsx"
route_file_content=$(cat "$router_file_path")

# Inject the Component
marker_page_index="<Route path=\"users\">"
line_to_check_before_inject="<Route path=\"${pluralize_kebabed_file_name}\">"

page_comp_to_inject="<Route path=\"${pluralize_kebabed_file_name}\">\n"
page_comp_to_inject+="                    <Route\n"
page_comp_to_inject+="                      index\n"
page_comp_to_inject+="                      element={\n"
page_comp_to_inject+="                        <PrivateRoute\n"
page_comp_to_inject+="                          element={<${pluralize_camelized_file_name}Index menuCode=\"CUST_${uppercased_file_name}\" />}\n"
page_comp_to_inject+="                        />\n"
page_comp_to_inject+="                      }\n"
page_comp_to_inject+="                    />\n"
page_comp_to_inject+="                  </Route>"

if [[ "$route_file_content" =~ $marker_page_index ]]; then
  if grep -qF "$line_to_check_before_inject" "$router_file_path"; then
    echo "[CLIENT] 🟡:    - Route block already injected!"
  else
    modified_content_comp="${route_file_content//$marker_page_index/$page_comp_to_inject\n                  $marker_page_index}"
    echo -e "$modified_content_comp" > "$router_file_path"
    echo "[CLIENT] 🚀:    - Route block injected!"
  fi
else
  echo "[CLIENT] ❌:'$marker_page_index' not found in the input file."
fi

# Inject Importing the Component
route_file_content_1=$(cat "$router_file_path")
inject_import_page_index="// Inject Import Page Index!"
page_index_to_inject="import ${pluralize_camelized_file_name}Index from 'src/pages/${file_dir_name}/Index';"

if [[ "$route_file_content_1" =~ $inject_import_page_index ]]; then
  if grep -qF "$page_index_to_inject" "$router_file_path"; then
    echo "[CLIENT] 🟡:    - Page Import line already injected!"
  else
    modified_content="${route_file_content_1//$inject_import_page_index/$inject_import_page_index\n$page_index_to_inject}"
    echo -e "$modified_content" > "$router_file_path"
    echo "[CLIENT] 🚀:    - Page Import line injected!"
  fi
else
  echo "[CLIENT] ❌:'$inject_import_page_index' not found in the input file."
fi

# Inject sidebar menu item
sidebar_file_path="${PWD}/lcnc_client/src/utils/sidebarMenus.js"
sidebar_file_content=$(cat "$sidebar_file_path")
menu_item_to_check_before_inject="name: '${title_file_name}'"

menu_item_marker="// Inject Menu Item!"
menu_item_to_inject="  {\n"
menu_item_to_inject+="    name: '${title_file_name}',\n"
menu_item_to_inject+="    path: '/${pluralize_kebabed_file_name}',\n"
menu_item_to_inject+="    code: MENU_CODES.CUSTOM,\n"
menu_item_to_inject+="    submenu: null\n"
menu_item_to_inject+="  },"

if [[ "$sidebar_file_content" =~ $menu_item_marker ]]; then
  if grep -qF "$menu_item_to_check_before_inject" "$sidebar_file_path"; then
    echo "[CLIENT] 🟡:    - Menu Item already injected!"
  else
    modified_content="${sidebar_file_content//$menu_item_marker/$menu_item_marker\n$menu_item_to_inject}"
    echo -e "$modified_content" > "$sidebar_file_path"
    echo "[CLIENT] 🚀:    - Menu Item injected!"
  fi
else
  echo "[CLIENT] ❌:'$menu_item_marker' not found in the input file."
fi