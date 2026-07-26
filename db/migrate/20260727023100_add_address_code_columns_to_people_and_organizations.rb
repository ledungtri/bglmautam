class AddAddressCodeColumnsToPeopleAndOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :province_code, :integer
    add_column :people, :ward_code, :integer
    add_column :organizations, :province_code, :integer
    add_column :organizations, :ward_code, :integer
  end
end
