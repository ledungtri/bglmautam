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
      Guidance.where(teacher_id: teacher.id).update_all(person_id: teacher.person_id)
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
end