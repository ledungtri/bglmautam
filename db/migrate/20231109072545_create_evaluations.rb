class CreateEvaluations < ActiveRecord::Migration[5.0]
  def change
    create_table :evaluations do |t|
      t.string :content
      t.references :evaluable, polymorphic: true
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
