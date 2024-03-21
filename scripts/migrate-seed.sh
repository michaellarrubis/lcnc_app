#!/bin/bash

docker exec -w /lcnc_api/src/database/migrations lcnc_api node migrate up \
  && docker exec -w /lcnc_api/src/database/migrations lcnc_api node seed up