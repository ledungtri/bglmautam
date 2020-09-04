class AddYearToAttendances < ActiveRecord::Migration[5.0]
  def change
    add_column :attendances, :year, :integer
    Attendance.all.each do |att|
      att.year = Cell.find(att.cell_id).year
      att.save
    end
  end
end
