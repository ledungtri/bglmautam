class AddDeletedAtToInstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :instructions, :deleted_at, :datetime
    add_index :instructions, :deleted_at
  end
end
