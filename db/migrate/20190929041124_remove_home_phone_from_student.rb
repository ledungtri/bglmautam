class RemoveHomePhoneFromStudent < ActiveRecord::Migration[5.0]
  def change
    remove_column :students, :home_phone 
  end
end
