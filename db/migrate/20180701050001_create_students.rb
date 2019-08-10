class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :christian_name
      t.string :full_name
      t.string :gender
      t.string :phone
      t.date :date_birth
      t.string :place_birth
      t.date :date_baptism
      t.string :place_baptism
      t.date :date_communion
      t.string :place_communion
      t.date :date_confirmation
      t.string :place_confirmation
      t.date :date_declaration
      t.string :place_declaration
      t.string :street_number
      t.string :street_name
      t.string :ward
      t.string :district
      t.string :home_phone
      t.string :area
      t.string :father_christian_name
      t.string :father_full_name
      t.string :father_phone
      t.string :mother_christian_name
      t.string :mother_full_name
      t.string :mother_phone

      t.timestamps null: false
    end
  end
end
