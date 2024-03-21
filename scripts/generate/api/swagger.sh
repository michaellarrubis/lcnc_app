#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_api/src/__generated__/swagger" ]; then
  mkdir -p "${PWD}/lcnc_api/src/__generated__/swagger";
fi

initial_table_name="$1"
model_name="$initial_table_name"
shift

file_name=$(singularize "$model_name")
pluralize_model_name=$(pluralize "$model_name")

camelized_model_name=$(snake_case_to_camelCase "$model_name")
model_class_name=$(make_first_lowercase "$camelized_model_name")
pluralize_model_class_name=$(pluralize "$model_class_name")
pluralize_camelized_model_class_name=$(pluralize "$camelized_model_name")

kebabized_model_name=$(snake_case_to_kebab_case "$model_name")
route_model_name=$(pluralize "$kebabized_model_name")


echo "[API] 🚀: Swaggers"

generated_fields=""
for arg in "$@"; do
IFS=':' read -ra parts <<< "$arg"
column_name="${parts[0]}"
column_type="${parts[1]}"

column_type=$(make_lowercase "$column_type")
model_id=$(make_model_id "$column_name")

if ! is_type_exists "$column_type"; then
  column_type="string"
fi

if [ "$column_name" != "id" ]; then
  if [ "$column_type" != "references" ]; then
    if [ "$column_type" == "text" ]; then
      generated_fields+="
                \"$column_name\": {
                  \"type\": \"text\"
                },"
    fi

    if [ "$column_type" != "text" ]; then
      generated_fields+="
                \"$column_name\": {
                  \"type\": \"$column_type\"
                },"
    fi
  fi

  if [ "$column_type" == "references" ]; then
    generated_fields+="
                \"$model_id\": {
                  \"type\": \"number\"
                },"
  fi

  if [ "$arg" == "${@: -1}" ]; then
    generated_fields="${generated_fields%,}"
  fi
fi
done

generatedContent="
export const swaggerPaths = {
  \"/api/v1/${route_model_name}\": {
    \"get\": {
      \"tags\": [
        \"${camelized_model_name}\"
      ],
      \"summary\": \"All ${pluralize_camelized_model_class_name}\",
      \"description\": \"Will list all ${pluralize_camelized_model_class_name}\",
      \"parameters\": [
        {
          \"name\": \"search\",
          \"in\": \"query\",
          \"description\": \"Search by the fields.\",
          \"required\": false,
          \"schema\": {
            \"type\": \"string\"
          }
        }, 
        {
          \"name\": \"page\",
          \"in\": \"query\",
          \"description\": \"Page number. 1 is the default page.\",
          \"required\": false,
          \"schema\": {
            \"type\": \"number\"
          }
        },
        {
          \"name\": \"limit\",
          \"in\": \"query\",
          \"description\": \"Number of items per pagination. 10 is default limit.\",
          \"required\": false,
          \"schema\": {
            \"type\": \"integer\"
          }
        },
        {
          \"name\": \"all\",
          \"in\": \"query\",
          \"description\": \"If true, return all data. request query param limit and page will be ignored.\",
          \"required\": false,
          \"schema\": {
            \"type\": \"boolean\"
          }
        }
      ],
      \"responses\": {
        \"200\": {
          \"description\": \"Successful operation\",
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"properties\": {
                  \"data\": {
                    \"type\": \"object\",
                    \"properties\": {
                      \"total_items\": {
                        \"type\": \"integer\",
                        \"example\": 1
                      },
                      \"items\": {
                        \"type\": \"array\",
                        \"items\": {
                          \"type\": \"object\"
                        }
                      },
                      \"current_page\": {
                        \"type\": \"number\",
                        \"example\": 1
                      },
                      \"total_pages\": {
                        \"type\": \"number\",
                        \"example\": 1
                      }
                    }
                  },
                  \"message\": {
                    \"type\": \"string\",
                    \"example\": \"OK\"
                  },
                  \"statusCode\": {
                    \"type\": \"integer\",
                    \"example\": 200
                  }
                }
              }
            }
          }
        }
      }
    },
    \"post\": {
      \"tags\": [
        \"${camelized_model_name}\"
      ],
      \"summary\": \"New ${camelized_model_name}\",
      \"description\": \"Creates new ${camelized_model_name} record.\",
      \"parameters\": [],
      \"requestBody\": {
        \"content\": {
          \"application/json\": {
            \"schema\": {
              \"properties\": {$generated_fields            
              }
            }
          }
        }
      },
      \"responses\": {
        \"201\": {
          \"description\": \"Successful operation\",
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"properties\": {
                  \"data\": {
                    \"type\": \"object\"
                  },
                  \"message\": {
                    \"type\": \"string\",
                    \"example\": \"Created\"
                  },
                  \"statusCode\": {
                    \"type\": \"integer\",
                    \"example\": 201
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  \"/api/v1/${route_model_name}/{id}\": {
    \"get\": {
      \"tags\": [
        \"${camelized_model_name}\"
      ],
      \"summary\": \"Get ${camelized_model_name} record.\",
      \"description\": \"Get ${camelized_model_name} by ID.\",
      \"parameters\": [
        {
          \"name\": \"id\",
          \"in\": \"path\",
          \"description\": \"ID\",
          \"required\": true,
          \"schema\": {
            \"type\": \"string\"
          }
        }
      ],
      \"responses\": {
        \"200\": {
          \"description\": \"Successful operation\",
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"properties\": {
                  \"data\": {
                    \"type\": \"object\"
                  },
                  \"message\": {
                    \"type\": \"string\",
                    \"example\": \"OK\"
                  },
                  \"statusCode\": {
                    \"type\": \"integer\",
                    \"example\": 200
                  }
                }
              }
            }
          }
        }
      }
    },
    \"put\": {
      \"tags\": [
        \"${camelized_model_name}\"
      ],
      \"summary\": \"Update ${camelized_model_name} record.\",
      \"description\": \"Update ${camelized_model_name} by ID.\",
      \"consumes\": [
        \"application/json\"
      ],
      \"produces\": [
        \"application/json\"
      ],
      \"parameters\": [
        {
          \"name\": \"id\",
          \"in\": \"path\",
          \"description\": \"ID\",
          \"required\": true,
          \"schema\": {
            \"type\": \"string\"
          }
        }
      ],
      \"requestBody\": {
        \"content\": {
          \"application/json\": {
            \"schema\": {
              \"properties\": {$generated_fields
              }
            }
          }
        }
      },
      \"responses\": {
        \"200\": {
          \"description\": \"Successful operation\",
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"properties\": {
                  \"data\": {
                    \"type\": \"object\"
                  },
                  \"message\": {
                    \"type\": \"string\",
                    \"example\": \"OK\"
                  },
                  \"statusCode\": {
                    \"type\": \"integer\",
                    \"example\": 200
                  }
                }
              }
            }
          }
        }
      }
    },
    \"delete\": {
      \"tags\": [
        \"${camelized_model_name}\"
      ],
      \"summary\": \"Delete ${camelized_model_name} record\",
      \"description\": \"Soft-delete ${camelized_model_name} item from the table.\",
      \"parameters\": [
        {
          \"name\": \"id\",
          \"in\": \"path\",
          \"description\": \"ID\",
          \"required\": true,
          \"schema\": {
            \"type\": \"string\"
          }
        }
      ],
      \"responses\": {
        \"200\": {
          \"description\": \"Successful operation\",
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"properties\": {
                  \"message\": {
                    \"type\": \"string\",
                    \"example\": \"OK\"
                  },
                  \"statusCode\": {
                    \"type\": \"integer\",
                    \"example\": 200
                  }
                }
              }
            }
          }
        }
      }
    }
  },
  \"/api/v1/${route_model_name}/bulk-delete\": {
    \"delete\": {
      \"tags\": [
        \"${camelized_model_name}\"
      ],
      \"summary\": \"Delete ${camelized_model_name}s in Bulk.\",
      \"description\": \"Delete ${camelized_model_name} records in Bulk.\",
      \"parameters\": [],
      \"requestBody\": {
        \"content\": {
          \"application/json\": {
            \"schema\": {
              \"type\": \"object\",
              \"properties\": {
                \"ids\": {
                  \"type\": \"array\",
                  \"items\": {
                    \"type\": \"number\"
                  },
                  \"example\": [1, 2, 3]
                }
              }
            }
          }
        }
      },
      \"responses\": {
        \"200\": {
          \"description\": \"Successful operation\",
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"type\": \"object\",
                \"properties\": {
                  \"data\": {
                    \"type\": \"object\",
                    \"properties\": {
                      \"message\": {
                        \"type\": \"string\",
                        \"example\": \"Departments 10,12,14 deleted successfully\"
                      }, 
                      \"error\":{
                        \"type\": \"object\",
                        \"properties\": {
                          \"invalid_ids\": {
                            \"type\": \"array\",
                            \"example\": [1,2,3]
                          }
                        }
                      } 
                    }
                  },
                  \"message\": {
                    \"type\": \"string\",
                    \"example\": \"OK\"
                  },
                  \"statusCode\": {
                    \"type\": \"integer\",
                    \"example\": 200
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}"

if [ ! -f "${PWD}/lcnc_api/src/__generated__/swagger/${model_name}.ts" ]; then
  echo "[API] 🚀:    - Swagger file generated!"
else
  echo "[API] 🚀:    - Swagger file re-generated!"
fi

echo "$not_editable_files$generatedContent" > "${PWD}/lcnc_api/src/__generated__/swagger/${model_name}.ts"

if [ ! -f "${PWD}/lcnc_api/src/api/swagger/endpoints/${model_name}.ts" ]; then
content="
import { swaggerPaths } from '@/__generated__/swagger/${model_name}';

export const swaggerContent = {
  \"openapi\": \"3.0.0\",
  \"paths\": {
    ...swaggerPaths
  }
}"

echo "$editable_files$content" > "${PWD}/lcnc_api/src/api/swagger/endpoints/${model_name}.ts"
echo "[API] 🚀:    - Swagger editable file generated!"
fi