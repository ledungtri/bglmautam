class AddDeletedAtToAttendances < ActiveRecord::Migration[5.0]
  def change
    add_column :attendances, :deleted_at, :datetime
    add_index :attendances, :deleted_at
  end
end
