class AddSacramentColumnsToPeople < ActiveRecord::Migration[7.2]
  def change
    add_column :people, :date_baptism, :date
    add_column :people, :place_baptism, :string
    add_column :people, :date_communion, :date
    add_column :people, :place_communion, :string
    add_column :people, :date_confirmation, :date
    add_column :people, :place_confirmation, :string
    add_column :people, :date_declaration, :date
    add_column :people, :place_declaration, :string
  end
end
