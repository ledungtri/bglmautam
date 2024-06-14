class CreatePeople < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.string :christian_name
      t.string :name
      t.string :gender
      t.date :birth_date
      t.string :birth_place

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
