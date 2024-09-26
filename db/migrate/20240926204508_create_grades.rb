class CreateGrades < ActiveRecord::Migration[5.0]
  def change
    create_table :grades do |t|
      t.string :name
      t.float :value
      t.references :enrollment

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
