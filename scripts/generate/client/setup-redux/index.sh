#!/bin/bash
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_client/src/__generated__/store/" ]; then
  mkdir -p "${PWD}/lcnc_client/src/__generated__/store/"
fi

echo "[CLIENT] 🚀: Redux files"
bash ${PWD}/scripts/generate/client/setup-redux/actions.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-redux/types.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-redux/reducers.sh "$@"
