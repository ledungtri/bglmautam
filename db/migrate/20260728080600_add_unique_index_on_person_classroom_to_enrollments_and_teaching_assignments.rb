class AddUniqueIndexOnPersonClassroomToEnrollmentsAndTeachingAssignments < ActiveRecord::Migration[7.2]
  def change
    add_index :enrollments, [:person_id, :classroom_id], unique: true,
              where: "deleted_at IS NULL", name: "index_enrollments_unique_person_classroom"
    add_index :teaching_assignments, [:person_id, :classroom_id], unique: true,
              where: "deleted_at IS NULL", name: "index_teaching_assignments_unique_person_classroom"
  end
end
