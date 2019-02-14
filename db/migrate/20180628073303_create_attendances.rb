class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.string :result
      t.integer :student_id
      t.integer :cell_id

      t.timestamps null: false
    end
  end
end
