class AddSubstituteFieldsToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_column :attendances, :substitute_teacher_id, :integer
    add_column :attendances, :substitute_lesson, :string
  end
end
