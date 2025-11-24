class UpdateAttendancesAttendableType < ActiveRecord::Migration[7.2]
  def up
    Attendance.where(attendable_type: 'Guidance').update_all(attendable_type: 'TeachingAssignment')
  end

  def down
    Attendance.where(attendable_type: 'TeachingAssignment').update_all(attendable_type: 'Guidance')
  end
end
