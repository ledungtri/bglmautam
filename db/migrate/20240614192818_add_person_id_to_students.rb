class AddPersonIdToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :person_id, :integer
  end
end
