class AddPersonIdAndGenderToTeachers < ActiveRecord::Migration[5.0]
  def change
    add_column :teachers, :gender, :string
    add_column :teachers, :person_id, :integer
  end
end
