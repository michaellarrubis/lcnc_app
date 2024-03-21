#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"

initial_table_name="$1"
initialized_table_name="$initial_table_name"
shift

table_name=$(pluralize "$initialized_table_name")
model_name=$(snake_case_to_camelCase "$initialized_table_name")

output="import { DataTypes, Model } from 'sequelize';
import sequelize  from '@/loaders/sequelize' 

class ${model_name} extends Model {}

${model_name}.init(
  {"

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"
  model_id=$(make_model_id "$column_name")

  column_type=$(make_uppercase "$column_type")
  if ! is_type_exists "$column_type"; then
    column_type="STRING"
  fi
  sequelize_type="DataTypes.$column_type"

  if [ "$column_type" != "REFERENCES" ]; then
    if [ "$column_type" == "NUMBER" ]; then
      sequelize_type="DataTypes.INTEGER"
    fi

    if [ "$column_type" == "BOOLEAN" ]; then
      sequelize_type="DataTypes.BOOLEAN"
    fi

    if [ "$column_name" != "id" ]; then
      output+="
    $column_name: $sequelize_type,"
    fi
  fi

  if [ "$column_type" == "REFERENCES" ]; then
    output+="
    $model_id: DataTypes.INTEGER,"
  fi
done

output+="
    status: DataTypes.STRING,
    created_by: DataTypes.INTEGER,
    updated_by: DataTypes.INTEGER,
    deleted_by: DataTypes.INTEGER,
    created_at: DataTypes.DATE,
    updated_at: DataTypes.DATE,
    deleted_at: DataTypes.DATE,
  },
  {
    hooks: {
      beforeDestroy: (instance, options) => {
        // @ts-ignore: Unreachable code error
        instance.update({ deleted_by: options.deleted_by });
      }
    },
    sequelize,
    modelName: '${model_name}',
    tableName: '${table_name}',
    underscored: true,
    paranoid: true,
  }
);

export default ${model_name};"

singularize_model_name=$(singularize "${table_name}")

if [ -f "${PWD}/lcnc_api/src/database/models/current/${singularize_model_name}.model.ts" ]; then
  echo "[API] ❌:    - 'models/current/${singularize_model_name}.model.ts' already generated! You may edit the file!"
else
  echo "$output" > "${PWD}/lcnc_api/src/database/models/current/${singularize_model_name}.model.ts"

  echo "[API] 🚀:    - Model file generated!"
fi

