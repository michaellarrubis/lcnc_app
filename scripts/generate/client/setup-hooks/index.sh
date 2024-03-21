#!/bin/bash
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_client/src/__generated__/hooks/" ]; then
  mkdir -p "${PWD}/lcnc_client/src/__generated__/hooks/"
fi

echo "[CLIENT] 🚀: Hook files"
bash ${PWD}/scripts/generate/client/setup-hooks/page.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-hooks/component.sh "$@"

