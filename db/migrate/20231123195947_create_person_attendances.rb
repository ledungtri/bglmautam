class CreatePersonAttendances < ActiveRecord::Migration[5.0]
  def change
    create_table :attendances do |t|
      t.datetime :date
      t.string :status
      t.datetime :notice_date
      t.string :note
      t.references :attendable, polymorphic: true

      t.timestamps
      t.datetime :deleted_at
    end
  end
end
