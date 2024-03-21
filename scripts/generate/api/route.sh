#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_api/src/__generated__/routes/v1" ]; then
  mkdir -p "${PWD}/lcnc_api/src/__generated__/routes/v1";
fi

initial_table_name="$1"
model_name="$initial_table_name"
shift

file_name=$(singularize "$model_name")
pluralize_model_name=$(pluralize "$model_name")

camelized_model_name=$(snake_case_to_camelCase "$model_name")
interface_model_name=$(snake_case_to_camelCase "$file_name")

model_class_name=$(make_first_lowercase "$camelized_model_name")
pluralize_model_class_name=$(pluralize "$model_class_name")
pluralize_camelized_model_class_name=$(pluralize "$camelized_model_name")

kebabized_model_name=$(snake_case_to_kebab_case "$model_name")
route_model_name=$(pluralize "$kebabized_model_name")

generated_service_path="__generated__/services"
interface_file_path="ts/interfaces/${file_name}.ts"

echo "[API] 🚀: Routes"

if [ ! -f "${PWD}/lcnc_api/src/${generated_service_path}/${model_name}.service.ts" ]; then
  echo "[API] ❌:    - File '$generated_service_path/${model_name}.service.ts' doesn't exist yet!"
  echo "---------------------------------------------------------------------------"
  echo "|                                                                          |"
  echo "|  gen_api_service  <table_name>                                           |"
  echo "|                                                                          |"
  echo "---------------------------------------------------------------------------"
fi

if [ ! -f "${PWD}/lcnc_api/src/${interface_file_path}" ]; then
  echo "[API] ❌:    - File '$interface_file_path' doesn't exist yet!"
  echo "---------------------------------------------------------------------------"
  echo "|                                                                          |"
  echo "|  gen_api_interface  <table_name>                                         |"
  echo "|                                                                          |"
  echo "---------------------------------------------------------------------------"
fi


generated_lines=""
file_path="${PWD}/lcnc_api/src/__generated__/interfaces/${file_name}.ts"
interface_name="export interface I${interface_model_name}Main"
code_block=$(sed -n "/$interface_name {/,/}/p" "$file_path" | sed '1d;$d')

if [ -n "$code_block" ]; then
  while read -r line; do
    if [ -n "$line" ]; then
      key=$(echo "$line" | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $1); print $1}')
      value=$(echo "$line" | awk -F: '{gsub(/^[ \t]+|[ \t]+$/, "", $2); gsub(/;/, "", $2); print $2}')
      model_id=$(make_model_id "$key")

      if [ "$value" != "references" ]; then
        if [ "$value" == "text" ]; then
          value="string"
        fi

        if [ "$key" != "id" ]; then
          generated_lines+="
          $key: Joi.$value(),"
        fi
      fi

      if [ "$value" == "references" ]; then
        generated_lines+="
          $model_id: Joi.number(),"
      fi
    fi
  done <<< "$code_block"
else
  echo "Error: Interface '$interface_name' not found in file '$file_path'."
fi

generatedRoute="
import { Router, Request, Response, NextFunction } from 'express';
import { Container } from 'typedi';
import { celebrate, Joi } from 'celebrate';

import ${camelized_model_name}GeneratedService from '@/${generated_service_path}/${model_name}.service';
import middlewares from '@/api/middlewares'; 

const route = Router();
import { getHttpStatus } from '@/utils/rest_http_status';
import wrapAsync from '@/utils/asyncWrapper';

export const generatedEndpoints = [
  {
    routePath: '/',
    routeFn: route.get(
      '/',
      middlewares.isAuth, 
      middlewares.attachCurrentUser,
      celebrate({
        query: Joi.object({
          search: Joi.string(), 
          limit: Joi.number().positive().default(10),
          page: Joi.number().default(1),
          all: Joi.boolean().default(false),
        })
      }),
      wrapAsync(async (req: Request, res: Response, next: NextFunction) => {
        const ${model_class_name}GeneratedServiceInstance = Container.get(${camelized_model_name}GeneratedService);

        // @ts-ignore: Unreachable code error
        const data = await ${model_class_name}GeneratedServiceInstance.get${pluralize_camelized_model_class_name}(req.query);

        return res.status(200).json({
          data,
          ...getHttpStatus(200)
        });
      })
    )
  },
  {
    routePath: '/:id',
    routeFn: route.get(
      '/:id',
      middlewares.isAuth, 
      middlewares.attachCurrentUser,
      celebrate({
        params: Joi.object({
          id: Joi.string().required()
        })
      }),
      wrapAsync(async (req: Request, res: Response, next: NextFunction) => {
        const ${model_class_name}GeneratedServiceInstance = Container.get(${camelized_model_name}GeneratedService);
        
        // @ts-ignore: Unreachable code error
        const data = await ${model_class_name}GeneratedServiceInstance.get${camelized_model_name}ById(Number(req.params.id));

        return res.status(200).json({
          data,
          ...getHttpStatus(200)
        });
      })
    )
  },
  {
    routePath: '/',
    routeFn: route.post(
      '/',
      middlewares.isAuth,
      middlewares.attachCurrentUser,
      middlewares.validateUserAccess({
        CC03: ['can_add'],
      }),
      celebrate({
        body: Joi.object({$generated_lines
        }),
      }),
      wrapAsync(async (req: Request, res: Response, next: NextFunction) => {
        const ${model_class_name}GeneratedServiceInstance = Container.get(${camelized_model_name}GeneratedService);
        
        // @ts-ignore: Unreachable code error
        const data = await ${model_class_name}GeneratedServiceInstance.create${camelized_model_name}(req.currentUser, req.body);

        return res.status(201).json({
          data,
          ...getHttpStatus(201)
        });
      })
    )
  },
  {
    routePath: '/:id',
    routeFn: route.put(
      '/:id',
      middlewares.isAuth,
      middlewares.attachCurrentUser,
      middlewares.validateUserAccess({
        CC03: ['can_edit'],
      }),
      celebrate({
        params: Joi.object({
          id: Joi.string().required()
        }),
        body: Joi.object({$generated_lines
        }),
      }),
      wrapAsync(async (req: Request, res: Response, next: NextFunction) => {
        const ${model_class_name}GeneratedServiceInstance = Container.get(${camelized_model_name}GeneratedService);
        
        // @ts-ignore: Unreachable code error
        const data = await ${model_class_name}GeneratedServiceInstance.update${camelized_model_name}(req.currentUser, Number(req.params.id), req.body);

        return res.status(200).json({
          data,
          ...getHttpStatus(200)
        });
      })
    )
  },
  {
    routePath: '/:id',
    routeFn: route.delete(
      '/:id',
      middlewares.isAuth,
      middlewares.attachCurrentUser,
      middlewares.validateUserAccess({
        CC03: ['can_delete'],
      }),
      celebrate({
        params: Joi.object({
          id: Joi.string().required()
        }),
        body: Joi.object({ 
          ids: Joi.array().min(1).unique().items(Joi.number().required())
        }),
      }),
      wrapAsync(async (req: Request, res: Response, next: NextFunction) => {
        const ${model_class_name}GeneratedServiceInstance = Container.get(${camelized_model_name}GeneratedService);
        const isBulkDelete = req.params.id === 'bulk-delete'
        let data = {}
        
        if (isBulkDelete)
          // @ts-ignore: Unreachable code error
          data = await ${model_class_name}GeneratedServiceInstance.bulkDelete${camelized_model_name}(req.currentUser, req.body.ids);
        
        if (!isBulkDelete)
          // @ts-ignore: Unreachable code error
          data = await ${model_class_name}GeneratedServiceInstance.delete${camelized_model_name}(req.currentUser, Number(req.params.id));

        return res.status(200).json({
          data,
          ...getHttpStatus(200)
        });
      })
    )
  }
];

"

if [ ! -f "${PWD}/lcnc_api/src/__generated__/routes/v1/${model_name}.route.ts" ]; then
  echo "[API] 🚀:    - Route file generated!"
else
  echo "[API] 🚀:    - Route file re-generated!"
fi

echo "$not_editable_files$generatedRoute" > "${PWD}/lcnc_api/src/__generated__/routes/v1/${model_name}.route.ts"

# Define the marker
file_path="${PWD}/lcnc_api/src/api/routes/v1/index.route.ts"

inject_import_route="// Inject Imported Route Here!"
interface_to_inject="import ${model_class_name}Routes from '@/api/routes/v1/${model_name}.route';"

file_content=$(cat "$file_path")
if [[ "$file_content" =~ $inject_import_route ]]; then
  if grep -qF "$interface_to_inject" "$file_path"; then
    echo "[API] 🟡:    - Route Interface line already injected!"
  else
    modified_content="${file_content//$inject_import_route/$inject_import_route\n$interface_to_inject}"
    echo -e "$modified_content" > "$file_path"
    echo "[API] 🚀:    - Route Interface line injected!"
  fi
else
  echo "[API] ❌:    - '$inject_import_route' not found in the input file."
fi

inject_instantiated_route="// Inject Instantiated Route Here!"
model_to_inject="router.use('/${route_model_name}', ${model_class_name}Routes);"

file_content=$(cat "$file_path")
if [[ "$file_content" =~ $inject_instantiated_route ]]; then
  if grep -qF "$model_to_inject" "$file_path"; then
    echo "[API] 🟡:    - Route Model line already injected!"
  else
    modified_content="${file_content//$inject_instantiated_route/$inject_instantiated_route\n$model_to_inject}"
    echo -e "$modified_content" > "$file_path"
    echo "[API] 🚀:    - Route Model line injected!"
  fi
else
  echo "[API] ❌:    - '$inject_instantiated_route' not found in the input file."
fi

service_file_path="api/services/${file_name}.service"

if [ ! -f "${PWD}/lcnc_api/src/${service_file_path}.ts" ]; then
  echo "[API] ❌:    - File '$generated_service_path/${model_name}.service.ts' doesn't exist yet!"
  echo "---------------------------------------------------------------------------"
  echo "|                                                                          |"
  echo "|  gen_api_service  <table_name>                                           |"
  echo "|                                                                          |"
  echo "---------------------------------------------------------------------------"
fi

route_file_path="api/routes/v1/${file_name}.route.ts"

if [ ! -f "${PWD}/lcnc_api/src/$route_file_path" ]; then
route_content="
  import { Router, Request, Response, NextFunction } from 'express';
  import { Container } from 'typedi';
  import { celebrate, Joi } from 'celebrate';

  import ${camelized_model_name}Service from '@/${service_file_path}';
  import middlewares from '@/api/middlewares'; 

  const route = Router();
  import { getHttpStatus } from '@/utils/rest_http_status';
  import wrapAsync from '@/utils/asyncWrapper';

  import { generatedEndpoints } from '@/__generated__/routes/v1/${file_name}.route';

  // Use this array to append your custom api function
  // Check the usage on README.md file
  const customEndpoints = []

  const endpointList = [...generatedEndpoints, ...customEndpoints]
  endpointList.forEach(endpoint => {
    route.use(endpoint.routePath, endpoint.routeFn);
  });

  export default route;
"
echo "$editable_files$route_content" > "${PWD}/lcnc_api/src/api/routes/v1/${model_name}.route.ts"
echo "[API] 🚀:    - Route editable file generated!"
fi