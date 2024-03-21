#!/bin/bash
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"

echo ""
echo "[API] 🛠️: Generating API Files...."

bash ${PWD}/scripts/generate/api/migration/index.sh "$@" \
  && bash ${PWD}/scripts/generate/api/interface.sh "$@" \
  && bash ${PWD}/scripts/generate/api/service.sh "$@" \
  && bash ${PWD}/scripts/generate/api/route.sh "$@" \
  && bash ${PWD}/scripts/generate/api/swagger.sh "$@"
