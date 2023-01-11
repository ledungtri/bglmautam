class RenameCellsToClassrooms < ActiveRecord::Migration[5.0]
  def change
    rename_table :classrooms, :classrooms
  end
end
