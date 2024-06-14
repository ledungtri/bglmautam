class CreateAddresses < ActiveRecord::Migration[5.0]
  def change
    create_table :addresses do |t|
      t.string :street_number
      t.string :street_name
      t.string :ward
      t.string :district
      t.string :city
      t.string :area
      t.boolean :primary, default: false
      t.references :addressable, polymorphic: true

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
