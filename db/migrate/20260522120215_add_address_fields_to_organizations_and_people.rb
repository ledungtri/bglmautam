class AddAddressFieldsToOrganizationsAndPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :street_address, :string
    add_column :organizations, :province, :string

    add_column :people, :street_address, :string
    add_column :people, :province, :string
  end
end
