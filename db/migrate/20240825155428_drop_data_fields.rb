class DropDataFields < ActiveRecord::Migration[5.0]
  def change
    drop_table :data_fields
  end
end
