class AddCheckedToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :checked, :boolean
  end
end
