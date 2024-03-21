#!/bin/bash

bash ${PWD}/scripts/generate/logger.sh "$@" \
  && bash ${PWD}/scripts/generate/api/exec.sh "$@" \
  && bash ${PWD}/scripts/generate/client/exec.sh "$@"
