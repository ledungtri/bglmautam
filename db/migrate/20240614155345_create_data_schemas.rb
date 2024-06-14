class CreateDataSchemas < ActiveRecord::Migration[5.0]
  def change
    create_table :data_schemas do |t|
      t.string :key
      t.string :title
      t.string :entity
      t.jsonb :fields
      t.integer :weight

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
