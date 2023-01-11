class ChangeInstructionsToGuidances < ActiveRecord::Migration[5.0]
  def change
    rename_table :instructions, :guidances
  end
end
