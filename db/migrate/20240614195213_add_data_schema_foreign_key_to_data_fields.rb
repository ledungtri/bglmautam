class AddDataSchemaForeignKeyToDataFields < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :data_fields, :data_schemas
  end
end
