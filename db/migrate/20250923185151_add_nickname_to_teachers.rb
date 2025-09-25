class AddNicknameToTeachers < ActiveRecord::Migration[5.2]
  def change
    add_column :teachers, :nickname, :string
  end
end
