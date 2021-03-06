class MigrationController < ApplicationController
  before_action :auth, :admin?

  def set_end_of_year_result
    attendances = Attendance.where(year: @current_year, result: 'Đang Học')
    attendances.each do |attendance|
      attendance.result = 'Lên Lớp'
      attendance.save
    end
    redirect_to root_url
  end

  def create_new_cells
    year = 2020
    map = {
      'Khai Tâm' => [
        { '' => %w[A B] }
      ],
      'Rước Lễ' => [
        { '1' => %w[A B C D] },
        { '2' => %w[A B C] },
        { '3' => %w[A B C] }
      ],
      'Thêm Sức' => [
        { '1' => %w[A B C] },
        { '2' => %w[A B C] },
        { '3' => %w[A B C] }
      ],
      'Bao Đồng' => [
        { '1' => %w[A B] },
        { '2' => %w[A B] },
        { '3' => %w[A B] }
      ]
    }

    map.each_key do |grade|
      objs = map[grade]

      objs.each do |obj|
        obj.each_key do |level|
          obj[level].each do |left|
            group = if level == ''
                      left
                    else
                      level + left
                    end

            cell = Cell.new
            cell.year = year
            cell.grade = grade
            cell.group = group

            cell.save
          end
        end
      end
    end
    redirect_to root_url
  end

  def assign_new_cells
    mappings = new_class_mapping

    mappings.each_key do |old_cell_id|
      new_cell_id = mappings[old_cell_id]
      attendances = Attendance.where(cell_id: old_cell_id, result: 'Lên Lớp')
      attendances.each do |attendance|
        count = Attendance.joins(:cell)
                          .where('cells.year = ? and attendances.student_id = ?', attendance.cell.year + 1, attendance.student_id)
                          .count
        next unless count.zero?

        new_attendance = Attendance.new

        new_attendance.cell_id = new_cell_id
        new_attendance.student_id = attendance.student_id
        new_attendance.result = 'Đang Học'

        new_attendance.save
      end
    end
    redirect_to root_url
  end

  private

  def new_class_mapping
    current_cells = Cell.where(year: @current_year)
    next_year_cells = Cell.where(year: @current_year + 1)

    mappings = {}
    @non_matching_cells = []

    current_cells.each do |current_cell|
      grade = current_cell.grade
      group = current_cell.group

      level = group[0]

      new_cell_name = case level
                      when '3'
                        new_level = '1'
                        new_grade = case grade
                                    when 'Rước Lễ'
                                      'Thêm Sức'
                                    when 'Thêm Sức'
                                      'Bao Đồng'
                                    else
                                      ''
                                    end
                        new_group = new_level + group[1]
                        "#{new_grade} #{new_group}"
                      else
                        case grade
                        when 'Khai Tâm'
                          new_grade = 'Rước Lễ'
                          new_group = "1#{group}"
                          "#{new_grade} #{new_group}"
                        when 'Rước Lễ', 'Thêm Sức', 'Bao Đồng'
                          new_grade = grade
                          new_group = (level.to_i + 1).to_s + group[1]
                          "#{new_grade} #{new_group}"
                        else
                          ''
                        end
                      end
      matching_cell = next_year_cells.select { |c| c.name == new_cell_name }[0]
      if !matching_cell.nil?
        mappings[current_cell.id] = matching_cell.id
      else
        @non_matching_cells.push(current_cell.name)
      end
    end

    mappings
  end
end
