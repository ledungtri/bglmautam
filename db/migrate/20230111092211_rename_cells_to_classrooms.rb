class RenameCellsToClassrooms < ActiveRecord::Migration[5.0]
  def change
    rename_table :cells, :classrooms
  end
end
