class AddWeightToGrade < ActiveRecord::Migration[5.0]
  def change
    add_column :grades, :weight, :integer, default: 1
  end
end
