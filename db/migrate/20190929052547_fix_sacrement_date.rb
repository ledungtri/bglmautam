class FixSacrementDate < ActiveRecord::Migration[5.0]
  def change
    Student.with_deleted.each do |student|
      changed = false

      student.date_communion
      student.date_confirmation
      student.date_declaration

      if student.place_communion && student.place_communion == "Mẫu Tâm" && student.date_communion && student.date_communion.month != 6 && student.date_communion.month != 7
        student.date_communion = Date.new(student.date_communion.year, student.date_communion.day, student.date_communion.month)
        changed = true
      end
      if student.place_confirmation && student.place_confirmation == "Mẫu Tâm" && student.date_confirmation && student.date_confirmation.month != 6 && student.date_confirmation.month != 7 
        student.date_confirmation = Date.new(student.date_confirmation.year, student.date_confirmation.day, student.date_confirmation.month)
        changed = true
      end
      if student.place_declaration && student.place_declaration == "Mẫu Tâm" && student.date_declaration && student.date_declaration.month != 6 && student.date_declaration.month != 7
        student.date_declaration = Date.new(student.date_declaration.year, student.date_declaration.day, student.date_declaration.month)
        changed = true
      end

      if changed
        student.save!
      end
    end
  end
end
