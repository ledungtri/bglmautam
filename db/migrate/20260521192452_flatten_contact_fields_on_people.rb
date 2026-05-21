class FlattenContactFieldsOnPeople < ActiveRecord::Migration[7.2]
  def up
    add_column :people, :phone, :string
    add_column :people, :email, :string
    add_column :people, :street_number, :string
    add_column :people, :street_name, :string
    add_column :people, :ward, :string
    add_column :people, :district, :string
    add_column :people, :city, :string
    add_column :people, :area, :string

    execute <<~SQL
      UPDATE people p
      SET phone = ph.number
      FROM phones ph
      WHERE ph.phoneable_type = 'Person'
        AND ph.phoneable_id = p.id
        AND ph."primary" = true
        AND ph.deleted_at IS NULL
    SQL

    execute <<~SQL
      UPDATE people p
      SET email = em.address
      FROM emails em
      WHERE em.emailable_type = 'Person'
        AND em.emailable_id = p.id
        AND em."primary" = true
        AND em.deleted_at IS NULL
    SQL

    execute <<~SQL
      UPDATE people p
      SET street_number = ad.street_number,
          street_name   = ad.street_name,
          ward          = ad.ward,
          district      = ad.district,
          city          = ad.city,
          area          = ad.area
      FROM addresses ad
      WHERE ad.addressable_type = 'Person'
        AND ad.addressable_id = p.id
        AND ad."primary" = true
        AND ad.deleted_at IS NULL
    SQL
  end

  def down
    remove_column :people, :phone
    remove_column :people, :email
    remove_column :people, :street_number
    remove_column :people, :street_name
    remove_column :people, :ward
    remove_column :people, :district
    remove_column :people, :city
    remove_column :people, :area
  end
end
