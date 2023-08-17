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
    mappings = new_classroom_mappings
    same_classroom_mapping = mappings[:same_classroom_mapping]
    next_classroom_mapping = mappings[:next_classroom_mapping]

    Enrollment.where(classroom_id: same_classroom_mapping.keys, result: ['Lên Lớp', 'Học Lại', 'Dự Thính']).find_each do |enrollment|
      existing_enrollment = Enrollment.joins(:classroom)
        .where('classrooms.year = ? and enrollments.student_id = ?', enrollment.classroom.year + 1, enrollment.student_id)
        .first
      next if existing_enrollment

      mapping = enrollment.result == 'Lên Lớp' ? next_classroom_mapping : same_classroom_mapping
      Enrollment.create(classroom_id: mapping[enrollment.classroom_id], student_id: enrollment.student_id, result: 'Đang Học')
    end
    redirect_to root_url
  end

  private

  def new_classroom_mappings
    current_classrooms = Classroom.where(year: @current_year)
    next_year_classrooms = Classroom.where(year: @current_year + 1)

    same_classroom_mapping = {}
    next_classroom_mapping = {}

    current_classrooms.each do |current_classroom|
      matching_same_classroom = next_year_classrooms.find { |c| c.name == current_classroom.name }
      same_classroom_mapping[current_classroom.id] = matching_same_classroom.id if matching_same_classroom

      matching_next_classroom = next_year_classrooms.find { |c| c.name == next_classroom_name(current_classroom) }
      next_classroom_mapping[current_classroom.id] = matching_next_classroom.id if matching_next_classroom
    end

    { same_classroom_mapping: same_classroom_mapping, next_classroom_mapping: next_classroom_mapping }
  end

  def next_classroom_name(classroom)
    family = classroom.family
    level = classroom.level
    group = classroom.group

    new_family = family
    if level == 3
      new_family = case family
        when 'Khai Tâm'
          'Rước Lễ'
        when 'Rước Lễ'
          'Thêm Sức'
        when 'Thêm Sức'
          'Bao Đồng'
        else
          ''
        end
    end
    new_level = (level.presence || 0) + 1
    new_level = 1 if new_level == 4

    "#{new_family} #{new_level}#{group}".strip
  end
end
