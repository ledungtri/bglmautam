class AddDataToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :people, :data, :jsonb
  end
end
