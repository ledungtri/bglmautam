class CreateEmails < ActiveRecord::Migration[5.0]
  def change
    create_table :emails do |t|
      t.string :address
      t.boolean :primary, default: false
      t.references :emailable, polymorphic: true

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
