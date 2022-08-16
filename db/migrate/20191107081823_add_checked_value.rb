class AddCheckedValue < ActiveRecord::Migration[5.0]
  def change
    Student.with_deleted.all.each do |student|
      if !student.checked
        student.checked = false
        student.save
      end
    end
  end
end
