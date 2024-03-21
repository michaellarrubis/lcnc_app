#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"
source "${PWD}/scripts/utils/validate.sh"

validate_generated_existence "$@"


if [ ! -d "${PWD}/lcnc_api/src/__generated__/services" ]; then
  mkdir -p "${PWD}/lcnc_api/src/__generated__/services";
fi

initial_table_name="$1"
initialized_table_name="$initial_table_name"
shift

file_name=$(singularize "$initialized_table_name")
model_name=$(snake_case_to_camelCase "$file_name")
model_class_name=$(make_first_lowercase "$model_name")
pluralize_model_name=$(pluralize "$model_name")


echo "[API] 🚀: Services"

interface_file_path="ts/interfaces/${file_name}.ts"
if [ ! -f "${PWD}/lcnc_api/src/${interface_file_path}" ]; then
  echo "[API] ❌:    - File '$interface_file_path' doesn't exist yet!"
  echo "---------------------------------------------------------------------------"
  echo "|                                                                          |"
  echo "|  gen_api_interface  <table_name>                                         |"
  echo "|                                                                          |"
  echo "---------------------------------------------------------------------------"
fi

generated_includes=""
for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"

  column_type=$(make_lowercase "$column_type")
  singularize_model_name=$(singularize "${column_name}")
  camelized_reference_model_name=$(snake_case_to_camelCase "$singularize_model_name")
  ref_column_name=$(make_first_lowercase "$camelized_reference_model_name")
  model_id=$(make_model_id "$column_name")

  if [ "$column_type" == "references" ]; then
    generated_includes+="        
          {
            model: this.${ref_column_name}Model,
            as: '${singularize_model_name}',
            attributes: {exclude: ['deleted_by', 'deleted_at']}
          },
        "
  fi
done

generated_excludes=""
for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"

  column_type=$(make_lowercase "$column_type")
  singularize_model_name=$(singularize "${column_name}")
  camelized_reference_model_name=$(snake_case_to_camelCase "$singularize_model_name")

  if [ "$column_type" == "references" ]; then
    generated_excludes+=", '${camelized_reference_model_name}Id'"
  fi
done

content="
import Sequelize from 'sequelize';
import { Service, Inject } from 'typedi';
import createHttpError from 'http-errors';

import { _findByModelAndColumn, _paginate } from '@/utils/common';

import { IUser } from '@/ts/interfaces/base/user';
import {
  I${model_name}, 
  I${model_name}Results, 
  I${model_name}Input, 
  I${model_name}Payload, 
  I${model_name}ResponsePayload
} from '@/ts/interfaces/${file_name}';

const omit = (keys, obj) => 
  Object.fromEntries(
    Object.entries(obj)
      .filter(([k]) => !keys.includes(k))
  )
const excludedFields = [\"id\",  \"created_by\",  \"updated_by\",  \"deleted_by\",  \"created_at\",  \"updated_at\",  \"deleted_at\"];
const Op = Sequelize.Op;

@Service()
export default class ${model_name}GeneratedService {
  constructor("

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"

  column_type=$(make_lowercase "$column_type")
  singularize_model_name=$(singularize "${column_name}")
  camelized_reference_model_name=$(snake_case_to_camelCase "$singularize_model_name")
  ref_column_name=$(make_first_lowercase "$camelized_reference_model_name")

  if [ "$column_type" == "references" ]; then
    content+="
    @Inject('${ref_column_name}Model') private ${ref_column_name}Model: Models.${camelized_reference_model_name}Model,"
  fi
done

content+="
    @Inject('${model_class_name}Model') private ${model_class_name}Model: Models.${model_name}Model,
    @Inject('logger') private logger,
  ) {}
  
  public async get${pluralize_model_name}(filter: I${model_name}Payload): Promise<I${model_name}Results> {
    try {
      // @ts-ignore
      const fields = Object.keys(omit(excludedFields, this.${model_class_name}Model.getAttributes()));
      const filtersObj = { where: {} };
      if (filter?.search)  {
        filtersObj.where[Op.or] = fields.map(
          (item) => Sequelize.where(
            Sequelize.cast(Sequelize.col(item), 'varchar'), // Converts !string data types to make it searchable
            { [Op.iLike]: \`%\${filter.search}%\` }
          )
        );
      }

      let query = {
        include: [$generated_includes],
        attributes: {exclude: ['deleted_by', 'deleted_at'$generated_excludes]},
        order: [['id', 'ASC']]
      }

      if(!filter.all){
        query = {
          ...query,
          ...filtersObj,
          ..._paginate(filter.page, filter.limit),
        }
      }

      // @ts-ignore
      const response: I${model_name}ResponsePayload = await this.${model_class_name}Model.findAndCountAll(query);

      return {
        total_items:  response.count,
        items: response.rows,
        current_page: filter.page,
        total_pages: (!filter.all) ? Math.ceil(response.count / filter.limit) : filter.page
      }
    }
    catch (e) {
      this.logger.error(e);
      throw createHttpError(e);
    }
  };

  public async get${model_name}ById(id: number): Promise<I${model_name}> {
    try {
      // @ts-ignore: Unreachable code error
      let result =  await this.${model_class_name}Model.findOne({
        where: { id },
        include: [$generated_includes],
        attributes: {exclude: ['deleted_by', 'deleted_at'$generated_excludes]}
      });
      if (!result) throw createHttpError.NotFound('${model_name} not found.');

      return result;
    }
    catch (e) {
      this.logger.error(e);
      throw createHttpError(e);
    }
  };

  public async create${model_name}(currentUser: IUser, payload: I${model_name}Input): Promise<I${model_name}> {
    try {
      let createPayload = {
        ...payload,
        created_by: Number(currentUser.id)
      };

      // @ts-ignore: Unreachable code error
      const newData = await this.${model_class_name}Model.create(createPayload);

      return await this.get${model_name}ById(newData.id);
    }
    catch (e) {
      this.logger.error(e);
      throw createHttpError(e);
    }
  };

  public async update${model_name}(currentUser: IUser, paramsId: number, payload: I${model_name}Input): Promise<I${model_name}> {
    try {
      let result = await _findByModelAndColumn(this.${model_class_name}Model, { id: paramsId });
      if (!result) throw createHttpError.NotFound('${model_name} not found.');

      let updatePayload = {
        ...payload,
        updated_by: Number(currentUser.id)
      };

      await this.${model_class_name}Model.update(updatePayload, {
        where: { id: paramsId }
      });

      return await this.get${model_name}ById(paramsId);
    }
    catch (e) {
      this.logger.error(e);
      throw createHttpError(e);
    }
  };

  public async delete${model_name}(currentUser: IUser, id: number): Promise<{ message: string }> {
    try {
      let record = await _findByModelAndColumn(this.${model_class_name}Model, { id });
      if (!record) throw createHttpError.NotFound('${model_name} not found.');

      try{
        // @ts-ignore: Unreachable code error
        await this.${model_class_name}Model.update(
          { ...record,
            deleted_by: Number(currentUser.id), 
            deleted_at: new Date()
          }, {
            where: { id: record.id }
          }
        );

        return { message: '${model_name} deleted successfully' };

      } catch(e){
        if(e.message.includes('violates foreign key constraint')){
          let index = parseInt(e.message.lastIndexOf(\"table\")) + 5;
          let conflict_table = e.message.slice(index);

          throw createHttpError.MethodNotAllowed(\`Unable to delete data due to being used on \${conflict_table.trim()}.\`)
        }
        else{
          throw createHttpError.InternalServerError(e.message)
        }
      }
    }
    catch (e) {
      this.logger.error(e);
      throw createHttpError(e);
    }
  };

  public async bulkDelete${model_name}(currentUser: IUser, ids: number[]) {
    try {
      const invalid = [];
      const valid = [];

      await Promise.all(
        ids.map(async id =>{
          const record = await _findByModelAndColumn(this.${model_class_name}Model, { id });

          try {
            // @ts-ignore: Unreachable code error
            await this.${model_class_name}Model.update(
              { ...record,
                deleted_by: Number(currentUser.id), 
                deleted_at: new Date()
              }, {
                where: { id }
              }
            );

            valid.push(id);
          }
          catch(e){
            invalid.push(id);
          }

        })
      );

      let message = \`\${valid} deleted successfully.\`;
      if (invalid.length > 0 && valid.length === 0) {
        message = 'Unable to delete due to foreign key constraints.'
      } else if (invalid.length > 0 && valid.length > 0) {
        message += ' Some unable to delete. Please check.'
      }

      return {
        message: message,
        error: {
          invalid_ids: invalid
        }
      };
    } catch (e) {
      this.logger.error(e);
      throw createHttpError(e);
    }
  };
}"

if [ ! -f "${PWD}/lcnc_api/src/__generated__/services/${file_name}.service.ts" ]; then
  echo "[API] 🚀:    - Service file generated!"
else
  echo "[API] 🚀:    - Service file re-generated!"
fi

echo "$not_editable_files$content" > "${PWD}/lcnc_api/src/__generated__/services/${file_name}.service.ts"

service_file_path="api/services/${file_name}.service.ts"

if [ ! -f "${PWD}/lcnc_api/src/$service_file_path" ]; then
service_content="
  import Sequelize from 'sequelize';
  import { Service, Inject } from 'typedi';
  import createHttpError from 'http-errors';

  import {
    I${model_name}, 
    I${model_name}Results, 
    I${model_name}Input, 
    I${model_name}Payload, 
    I${model_name}ResponsePayload
  } from '@/ts/interfaces/${file_name}';

  const Op = Sequelize.Op;

  @Service()
  export default class ${model_name}Service {
    constructor(
      @Inject('${model_class_name}Model') private ${model_class_name}Model: Models.${model_name}Model,
      @Inject('logger') private logger,
    ) {}

    // You may or may not use this function!
    public async customFunction(): Promise<[]> {
      // You can insert your logic here!
      try {
        return [];
      }
      catch (e) {
        this.logger.error(e);
        throw createHttpError(e);
      }
    };
  }
"
echo "$editable_files$service_content" > "${PWD}/lcnc_api/src/api/services/${file_name}.service.ts"
echo "[API] 🚀:    - Service editable file generated!"
fi