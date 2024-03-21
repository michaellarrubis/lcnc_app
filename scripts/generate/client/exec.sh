#!/bin/bash
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"

echo ""
echo "[CLIENT] 🛠️: Generating CLIENT Files...."

bash ${PWD}/scripts/generate/client/setup-api.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-redux/index.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-hooks/index.sh "$@" \
  && bash ${PWD}/scripts/generate/client/setup-page/index.sh "$@"
