class MigrationController < ApplicationController
  before_action :auth, :admin?

  def set_end_of_year_result
    Enrollment.joins(:classroom).where("classrooms.year = #{@current_year}").where(result: 'Đang Học').find_each do |enrollment|
      enrollment.result = 'Lên Lớp'
      enrollment.save
    end
    redirect_to root_url
  end

  def create_new_classrooms
    year = 2020
    map = {
      'Khai Tâm' => [
        { '' => [''] }
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

    map.each_key do |family|
      objs = map[family]

      objs.each do |obj|
        obj.each_key do |level|
          obj[level].each do |group|
            Classroom.create(year: year, family: family, level: level, group: group)
          end
        end
      end
    end
    redirect_to root_url
  end

  def assign_new_classrooms
    mappings = new_classroom_mapping

    mappings.each do |old_classroom_id, new_classroom_id|
      enrollments = Enrollment.where(cell_id: old_classroom_id, result: ['Lên Lớp', 'Dự Thính'])
      enrollments.each do |enrollment|
        count = Enrollment.joins(:classroom)
                          .where('classrooms.year = ? and enrollments.student_id = ?', enrollment.classroom.year + 1, enrollment.student_id)
                          .count
        next unless count.zero?

        new_enrollment = Enrollment.new

        new_enrollment.classroom_id = new_classroom_id
        new_enrollment.student_id = enrollment.student_id
        new_enrollment.result = 'Đang Học'

        new_enrollment.save
      end
    end
    redirect_to root_url
  end

  private

  def new_classroom_mapping
    current_classrooms = Classroom.where(year: @current_year)
    next_year_classrooms = Classroom.where(year: @current_year + 1)

    mappings = {}
    @non_matching_classrooms = []

    current_classrooms.each do |current_classroom|
      family = current_classroom.family
      level = current_classroom.level
      group = current_classroom.group

      new_classroom_name = case level
                      when '3'
                        new_level = '1'
                        new_family = case family
                                    when 'Rước Lễ'
                                      'Thêm Sức'
                                    when 'Thêm Sức'
                                      'Bao Đồng'
                                    else
                                      ''
                                    end
                        "#{new_family} #{new_level}#{group}"
                      else
                        case family
                        when 'Khai Tâm'
                          new_family = 'Rước Lễ'
                          "#{new_family} 1#{group}"
                        when 'Rước Lễ', 'Thêm Sức', 'Bao Đồng'
                          new_level = level + 1
                          "#{family} #{new_level}#{group}"
                        else
                          ''
                        end
                      end
      matching_classroom = next_year_classrooms.select { |c| c.name == new_classroom_name }[0]
      if !matching_classroom.nil?
        mappings[current_classroom.id] = matching_classroom.id
      else
        @non_matching_classrooms.push(current_classroom.name)
      end
    end

    mappings
  end
end
