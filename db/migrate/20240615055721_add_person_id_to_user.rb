class AddPersonIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :person, index: true, foreign_key: true
  end
end
