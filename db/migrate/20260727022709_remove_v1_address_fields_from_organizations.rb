class RemoveV1AddressFieldsFromOrganizations < ActiveRecord::Migration[7.2]
  def change
    remove_column :organizations, :street_number, :string
    remove_column :organizations, :street_name, :string
    remove_column :organizations, :ward, :string
    remove_column :organizations, :district, :string
    remove_column :organizations, :city, :string
  end
end
