#!/bin/bash

cp ${PWD}/.env.sample ${PWD}/.env \
  && cp ${PWD}/lcnc_api/.env.sample ${PWD}/lcnc_api/.env \
  && bash ${PWD}/lcnc_api/scripts/create_keys.sh \
  && bash ${PWD}/scripts/export-shortcuts.sh "${PWD}"
  && docker-compose build --no-cache \
  && docker-compose up