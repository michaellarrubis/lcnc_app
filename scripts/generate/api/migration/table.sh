#!/bin/bash
source "${PWD}/scripts/utils/helpers.sh"

initial_table_name="$1"
initialized_table_name="$initial_table_name"
shift

table_name=$(pluralize "$initialized_table_name")
delete_duplicates_in_directory "${PWD}/lcnc_api/src/database/migrations/files" "$table_name.ts"

docker exec -w /lcnc_api/src/database/migrations lcnc_api node migrate create --folder ./files --name $table_name.ts

output="import { DataTypes, Sequelize } from 'sequelize';
import { Migration } from '@/database/migrations/run';

export const up: Migration = async ({ context: sequelize }) => {
  await sequelize.getQueryInterface().createTable('${table_name}', {
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      primaryKey: true,
      autoIncrement: true
    },"

for arg in "$@"; do
  IFS=':' read -ra parts <<< "$arg"
  column_name="${parts[0]}"
  column_type="${parts[1]}"
  field_type="${parts[2]}"
  unique_value=""

  column_type=$(make_uppercase "$column_type")
  model_id=$(make_model_id "$column_name")

  if ! is_type_exists "$column_type"; then
    column_type="STRING"
  fi
  sequelize_type="DataTypes.$column_type"

  if [ "$column_type" == "NUMBER" ]; then
    sequelize_type="DataTypes.INTEGER"
  fi

  if [ "$column_type" == "BOOLEAN" ]; then
    sequelize_type="DataTypes.BOOLEAN"
  fi

  if [ "$field_type" == "unique" ]; then
    unique_value="unique: true,"
  fi

  if [ "$column_name" != "id" ] && [ "$column_type" != "REFERENCES" ]; then
    output+="
    $column_name: {
      $unique_value
      type: $sequelize_type,
    },"
  fi

  if [ "$column_name" != "id" ] && [ "$column_type" == "REFERENCES" ]; then
    output+="
    $model_id: {
      $unique_value
      type: DataTypes.INTEGER,
      allowNull: true,
      references: {
        model: '$column_name',
        key: 'id',
      },
      onDelete: 'SET NULL'
    },"
  fi
done

output+="
    status: {
      type: DataTypes.CHAR(1),
      defaultValue: 'A',
      allowNull: false,
    },
    created_by: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    updated_by: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    deleted_by: {
      type: DataTypes.INTEGER,
      allowNull: true
    },
    created_at: {
      type: DataTypes.DATE,
      allowNull: false,
      defaultValue: Sequelize.fn('now')
    },
    updated_at: {
      type: DataTypes.DATE,
      allowNull: true
    },
    deleted_at: {
      type: DataTypes.DATE,
      allowNull: true
    }
  })
};

export const down: Migration = async ({ context: sequelize }) => {
  await sequelize.getQueryInterface().dropTable('${table_name}');
};"

output_file=$(ls -1t "${PWD}/lcnc_api/src/database/migrations/files/" | head -n 1)

if [ -n "$output_file" ]; then
  echo "$output" > "${PWD}/lcnc_api/src/database/migrations/files/$output_file"
  echo ""
  echo "[API] 🚀:    - Table Migration file generated!"
fi
