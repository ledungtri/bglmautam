class AddClassroomForeignKeyToGuidancesAndEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :guidances, :classrooms
    add_foreign_key :enrollments, :classrooms
  end
end
