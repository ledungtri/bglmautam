class CreatePhones < ActiveRecord::Migration[5.0]
  def change
    create_table :phones do |t|
      t.string :number
      t.boolean :primary, default: false
      t.references :phoneable, polymorphic: true

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
