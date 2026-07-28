namespace :admin do
  task teachers_to_people: :environment do
    total = Teacher.count
    count = 0

    Teacher.find_each do |teacher|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Teacher Id: #{teacher.id}"
      teacher.sync_person
    end
  end

  task students_to_people: :environment do
    total = Student.count
    count = 0

    Student.find_each do |student|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Student Id: #{student.id}"
      student.sync_person
    end
  end

  task teacher_person_id: :environment do
    total = Teacher.count
    count = 0

    Teacher.find_each do |teacher|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Teacher Id: #{teacher.id}"
      User.where(teacher_id: teacher.id).update_all(person_id: teacher.person_id)
      TeachingAssignment.where(teacher_id: teacher.id).update_all(person_id: teacher.person_id)
    end
  end

  task student_person_id: :environment do
    total = Student.count
    count = 0

    Student.find_each do |student|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Student Id: #{student.id}"
      Enrollment.where(student_id: student.id).update_all(person_id: student.person_id)
    end
  end

  desc 'Audit person_id backfill coverage on enrollments/teaching_assignments before repointing FKs (Phase S step 5)'
  task audit_person_id_coverage: :environment do
    def report(label, count)
      puts "#{count.zero? ? 'OK' : 'FOUND'} - #{label}: #{count}"
    end

    puts '=== Enrollments ==='
    report('missing person_id (active)', Enrollment.where(person_id: nil).count)
    report('missing person_id (incl. soft-deleted)', Enrollment.with_deleted.where(person_id: nil).count)
    report(
      'person_id drift from student.person_id',
      Enrollment.with_deleted.joins(:student)
        .where.not('enrollments.person_id = students.person_id').count
    )
    report(
      'orphaned student_id (no matching Student)',
      Enrollment.with_deleted.where.not(student_id: Student.unscoped.select(:id)).count
    )

    puts '=== Teaching Assignments ==='
    report('missing person_id (active)', TeachingAssignment.where(person_id: nil).count)
    report('missing person_id (incl. soft-deleted)', TeachingAssignment.with_deleted.where(person_id: nil).count)
    report(
      'person_id drift from teacher.person_id',
      TeachingAssignment.with_deleted.joins(:teacher)
        .where.not('teaching_assignments.person_id = teachers.person_id').count
    )
    report(
      'orphaned teacher_id (no matching Teacher)',
      TeachingAssignment.with_deleted.where.not(teacher_id: Teacher.unscoped.select(:id)).count
    )
  end

  desc 'Verify Phase S steps 1-4: sacrament backfill coverage + parents_info sanity counts'
  task verify_sacrament_and_parents_info: :environment do
    def report(label, count)
      puts "#{count.zero? ? 'OK' : 'FOUND'} - #{label}: #{count}"
    end

    # Same mapping as db/migrate/20260727173631_backfill_sacrament_columns_on_people_from_students.rb
    mapping = {
      date_baptism: [:date_baptism, 'baptism_date'],
      place_baptism: [:place_baptism, 'baptism_place'],
      date_communion: [:date_communion, 'communion_date'],
      place_communion: [:place_communion, 'communion_place'],
      date_confirmation: [:date_confirmation, 'confirmation_date'],
      place_confirmation: [:place_confirmation, 'confirmation_place'],
      date_declaration: [:date_declaration, 'declaration_date'],
      place_declaration: [:place_declaration, 'declaration_place']
    }

    puts '=== Sacraments ==='
    missing = 0
    Student.unscoped.with_deleted.find_each do |student|
      person = student.person
      next unless person

      sacraments = person.data.is_a?(Hash) ? (person.data['sacraments'] || {}) : {}
      mapping.each do |person_column, (student_column, jsonb_key)|
        expected = student[student_column].presence || sacraments[jsonb_key].presence
        next unless expected.present?

        actual = person[person_column]
        missing += 1 if actual.blank? || actual.to_s != expected.to_s
      end
    end
    report('sacrament values present on Student/legacy data but missing/mismatched on Person', missing)

    puts '=== Parents Info (sanity counts, not a strict backfill check) ==='
    puts "People with non-empty parents_info custom field: #{Person.where("data -> 'parents_info' IS NOT NULL AND data -> 'parents_info' != '{}'").count}"
    puts "Students with legacy father/mother data present: #{Student.unscoped.with_deleted.select { |s| s.father_full_name.presence || s.mother_full_name.presence }.count}"
  end
end