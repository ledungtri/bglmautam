class AddContactFieldsToOrganizations < ActiveRecord::Migration[7.2]
  def change
    add_column :organizations, :phone, :string
    add_column :organizations, :email, :string
    add_column :organizations, :street_number, :string
    add_column :organizations, :street_name, :string
    add_column :organizations, :ward, :string
    add_column :organizations, :district, :string
    add_column :organizations, :city, :string
  end
end
