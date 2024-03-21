#!/bin/bash
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


echo "[CLIENT] 🚀: Page files"
bash ${PWD}/scripts/generate/client/setup-page/page-index.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-page/add-edit-modal.sh "$@"
