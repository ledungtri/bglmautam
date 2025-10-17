class AddAvatarUrlToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :avatar_url, :string
  end
end
