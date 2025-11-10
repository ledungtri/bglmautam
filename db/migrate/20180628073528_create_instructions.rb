class CreateInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :instructions do |t|
      t.string :position
      t.integer :teacher_id
      t.integer :cell_id

      t.timestamps null: false
    end
  end
end
