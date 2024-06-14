class ChangeDataSchemaColumns < ActiveRecord::Migration[5.0]
  def change
    change_column :data_schemas, :key, :string, null: false
    change_column :data_schemas, :entity, :string, null: false
    change_column :data_schemas, :weight, :integer, null: false, default: 0
  end
end
