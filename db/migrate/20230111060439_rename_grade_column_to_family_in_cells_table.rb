class RenameGradeColumnToFamilyInCellsTable < ActiveRecord::Migration[5.0]
  def change
    rename_column :cells, :grade, :family
  end
end
