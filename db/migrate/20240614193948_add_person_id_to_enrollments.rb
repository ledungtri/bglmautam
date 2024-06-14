class AddPersonIdToEnrollments < ActiveRecord::Migration[5.0]
  def change
    add_reference :enrollments, :person, index: true, foreign_key: true
  end
end
