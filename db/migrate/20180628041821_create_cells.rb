class CreateCells < ActiveRecord::Migration[5.2]
  def change
    create_table :cells do |t|
      t.integer :year
      t.string :grade
      t.string :group
      t.string :location

      t.timestamps null: false
    end
  end
end
