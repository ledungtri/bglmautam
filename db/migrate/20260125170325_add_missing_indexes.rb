class AddMissingIndexes < ActiveRecord::Migration[7.2]
  def change
    # Enrollments - frequently queried by student_id and classroom_id
    add_index :enrollments, :student_id, if_not_exists: true
    add_index :enrollments, :classroom_id, if_not_exists: true
    # Partial unique index - only for non-deleted records (paranoia compatibility)
    add_index :enrollments, [:student_id, :classroom_id],
              unique: true,
              where: 'deleted_at IS NULL',
              name: 'index_enrollments_unique_student_classroom',
              if_not_exists: true

    # Teaching assignments - frequently queried by teacher_id and classroom_id
    add_index :teaching_assignments, :teacher_id, if_not_exists: true
    add_index :teaching_assignments, :classroom_id, if_not_exists: true
    # Partial unique index - only for non-deleted records (paranoia compatibility)
    add_index :teaching_assignments, [:teacher_id, :classroom_id],
              unique: true,
              where: 'deleted_at IS NULL',
              name: 'index_teaching_assignments_unique_teacher_classroom',
              if_not_exists: true

    # Attendances - polymorphic association and frequently queried by date
    add_index :attendances, [:attendable_type, :attendable_id], if_not_exists: true
    add_index :attendances, [:attendable_type, :attendable_id, :date], if_not_exists: true

    # Grades - frequently queried by enrollment
    add_index :grades, :enrollment_id, if_not_exists: true

    # Evaluations - polymorphic association
    add_index :evaluations, [:evaluable_type, :evaluable_id], if_not_exists: true
  end
end
