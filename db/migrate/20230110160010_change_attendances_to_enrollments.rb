class ChangeAttendancesToEnrollments < ActiveRecord::Migration[5.0]
  def change
    rename_table :attendances, :enrollments
  end
end
