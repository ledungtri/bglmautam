# frozen_string_literal: true

namespace :admin do
  task conclude_result: :environment do
    require "tty-prompt"
    prompt = TTY::Prompt.new

    year = prompt.ask("Năm Học?", convert: :integer)
    Enrollment.for_year(year).where(result: 'Đang Học').update_all(result: 'Lên Lớp')
  end

  task populate_new_year_classrooms: :environment do
    require "tty-prompt"
    prompt = TTY::Prompt.new

    year = prompt.ask("Năm Học?", convert: :integer)
    alphabet = ("A".."Z").to_a

    kt_size = prompt.ask("Bao nhiêu lớp Khai Tâm?", convert: :integer)
    case kt_size
    when 1
      Classroom.create(year: year, family: 'Khai Tâm', level: '', group: '')
    when 2..24
      (1..kt_size).each { |i| Classroom.create(year: year, family: 'Khai Tâm', level: '', group: alphabet[i - 1]) }
    end

    ['Rước Lễ', 'Thêm Sức', 'Bao Đồng'].each do |family|
      [1, 2, 3].each do |level|
        size = prompt.ask("Bao nhiêu lớp #{family} #{level}?", convert: :integer)

        case size
        when 1
          Classroom.create(year: year, family: family, level: level, group: '')
        when 2..24
          (1..size).each { |i| Classroom.create(year: year, family: family, level: level, group: alphabet[i - 1]) }
        end
      end
    end
  end

  task assign_new_classrooms: :environment do
    def next_classroom_name(classroom)
      family = classroom.level == 3 ?
                     case classroom.family
                     when 'Khai Tâm'
                       'Rước Lễ'
                     when 'Rước Lễ'
                       'Thêm Sức'
                     when 'Thêm Sức'
                       'Bao Đồng'
                     else
                       ''
                     end : classroom.family
      level = (classroom.level.presence || 0) + 1
      level = level - 3 if level > 3

      "#{family} #{level}#{classroom.group}".strip
    end

    require "tty-prompt"
    prompt = TTY::Prompt.new

    year = prompt.ask("Năm Học hiện tại?", convert: :integer)
    current_classrooms = Classroom.where(year: year)
    next_year_classrooms = Classroom.where(year: year + 1)

    same_classroom_mapping = {}
    next_classroom_mapping = {}

    current_classrooms.each do |current_classroom|
      matching_same_classroom = next_year_classrooms.find { |c| c.name == current_classroom.name }
      same_classroom_mapping[current_classroom.id] = matching_same_classroom.id if matching_same_classroom

      matching_next_classroom = next_year_classrooms.find { |c| c.name == next_classroom_name(current_classroom) }
      next_classroom_mapping[current_classroom.id] = matching_next_classroom.id if matching_next_classroom
    end

    current_enrollments = Enrollment.for_year(year).where(result: ['Lên Lớp', 'Học Lại', 'Dự Thính'])
    existing_new_enrollments = Enrollment.for_year(year + 1)
    current_enrollments.each do |enrollment|
      existing_enrollment = existing_new_enrollments.find { |e| e.student_id == enrollment.student_id }
      next if existing_enrollment

      mapping = enrollment.result == 'Lên Lớp' ? next_classroom_mapping : same_classroom_mapping
      Enrollment.create(classroom_id: mapping[enrollment.classroom_id], student_id: enrollment.student_id, result: 'Đang Học')
    end
  end
end
