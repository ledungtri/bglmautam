class RenameCellIdToClassroomId < ActiveRecord::Migration[5.0]
  def change
    rename_column :enrollments, :cell_id, :classroom_id
    rename_column :guidances, :cell_id, :classroom_id
  end
end
