class CreateDataFields < ActiveRecord::Migration[5.0]
  def change
    create_table :data_fields do |t|
      t.jsonb :data
      t.references :data_fieldable, polymorphic: true
      t.references :data_schema

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
