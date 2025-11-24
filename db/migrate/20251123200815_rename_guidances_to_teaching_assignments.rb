class RenameGuidancesToTeachingAssignments < ActiveRecord::Migration[7.2]
  def change
    rename_table :guidances, :teaching_assignments
  end
end
