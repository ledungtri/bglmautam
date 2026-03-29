class AddReasonToAttendances < ActiveRecord::Migration[7.2]
  def change
    add_column :attendances, :reason, :string
  end
end
