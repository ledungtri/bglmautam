class AddIsAdminToTeacher < ActiveRecord::Migration[5.0]
  def change
    add_column :teachers, :is_admin, :boolean
  end
end
