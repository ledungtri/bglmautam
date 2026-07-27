class AddOrganizationIdToVersions < ActiveRecord::Migration[7.2]
  def change
    add_reference :versions, :organization, null: true, foreign_key: true, index: true
  end
end
