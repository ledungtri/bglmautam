class AddNicknameToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :nickname, :string
  end
end
