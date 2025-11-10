class CreateTeachers < ActiveRecord::Migration[5.2]
def change
    create_table :teachers do |t|
      t.string :christian_name
      t.string :full_name
      t.string :named_date
      t.date :date_birth
      t.string :occupation
      t.string :phone
      t.string :email
      t.string :street_number
      t.string :street_name
      t.string :ward
      t.string :district

      t.timestamps null: false
    end
  end
end
