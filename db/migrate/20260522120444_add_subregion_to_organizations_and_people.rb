class AddSubregionToOrganizationsAndPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :subregion, :string
    add_column :people, :subregion, :string
  end
end
