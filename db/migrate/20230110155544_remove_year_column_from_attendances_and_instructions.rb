class RemoveYearColumnFromAttendancesAndInstructions < ActiveRecord::Migration[5.0]
  def change
    remove_columns :attendances, :year
    remove_columns :instructions, :year
  end
end
