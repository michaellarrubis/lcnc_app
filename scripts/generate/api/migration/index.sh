#!/bin/bash
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


echo "[API] 🚀: Migrations"
echo ""
echo ""
echo "....."
echo ""
bash ${PWD}/scripts/generate/api/migration/table.sh "$@" \
  && bash ${PWD}/scripts/generate/api/migration/model.sh "$@" \
  && bash ${PWD}/scripts/generate/api/migration/associate.sh "$@"

echo ""
echo ""
echo "[API] PENDING MIGRATION 👉🏻: gen_migrate up"
echo ""
echo ""
