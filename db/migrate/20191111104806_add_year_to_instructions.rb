class AddYearToInstructions < ActiveRecord::Migration[5.0]
  def change
    add_column :instructions, :year, :integer
    Instruction.all.each do |ins|
      ins.year = Cell.find(ins.cell_id).year
      ins.save
    end
  end
end
