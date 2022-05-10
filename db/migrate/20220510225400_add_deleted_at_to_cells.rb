class AddDeletedAtToCells < ActiveRecord::Migration[5.0]
  def change
    add_column :cells, :deleted_at, :datetime
    add_index :cells, :deleted_at
  end
end
