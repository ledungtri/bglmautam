class RemoveIsAdminAndPasswordDigestColumnsFromTeacher < ActiveRecord::Migration[5.0]
  def change
    remove_columns :teachers, :is_admin, :password_digest
  end
end
