class AddLevelColumnToCells < ActiveRecord::Migration[5.0]
  def change
    add_column :cells, :level, :integer
  end
end
