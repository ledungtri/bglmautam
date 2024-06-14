class AddPersonIdToGuidances < ActiveRecord::Migration[5.0]
  def change
    add_reference :guidances, :person, index: true, foreign_key: true
  end
end
