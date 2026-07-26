class CreateVnAddressReferenceTables < ActiveRecord::Migration[7.2]
  def change
    create_table :vn_provinces, id: false do |t|
      t.integer :code, primary_key: true
      t.string :name, null: false
      t.string :division_type
      t.string :codename
      t.integer :phone_code
    end

    create_table :vn_districts, id: false do |t|
      t.integer :code, primary_key: true
      t.string :name, null: false
      t.string :division_type
      t.string :codename
      t.integer :province_code, null: false
    end
    add_index :vn_districts, :province_code

    create_table :vn_wards, id: false do |t|
      t.integer :code, primary_key: true
      t.string :name, null: false
      t.string :division_type
      t.string :codename
      t.integer :district_code, null: false
    end
    add_index :vn_wards, :district_code
  end
end
