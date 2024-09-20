class CreateResourceTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :resource_types do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.string :weight, null: false, default: 0

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
