class PopulateCellsLevel < ActiveRecord::Migration[5.0]
  def change
    Cell.find_each do |cell|
      next unless cell.group

      if cell.group.length == 2
        cell.level = cell.group[0]
        cell.group = cell.group[1]
      elsif cell.group.length == 1 && cell.grade != 'Khai Tâm'
        cell.level = cell.group
        cell.group = nil
      end
      cell.save
    end
  end
end
