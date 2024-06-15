namespace :admin do
  task teachers_to_people: :environment do
    total = Teacher.count
    count = 0

    Teacher.find_each do |teacher|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Teacher Id: #{teacher.id}"

      person = teacher.person_id ? Person.find(teacher.person_id) : Person.new
      person.christian_name = teacher.christian_name
      person.name = teacher.full_name
      person.gender = teacher.gender
      person.birth_date = teacher.date_birth
      person.save

      unless teacher.person_id
        teacher.person_id = person.id
        teacher.save
      end

      person.phones.where(primary: true).first_or_initialize(number: teacher.phone).save unless teacher.phone.blank?
      person.emails.where(primary: true).first_or_initialize(address: teacher.email).save unless teacher.email.blank?
      person.addresses.where(primary: true).first_or_initialize(
        street_number: teacher.street_number,
        street_name: teacher.street_name,
        ward: teacher.ward,
        district: teacher.district
      ).save unless teacher.street_name.blank?
      person.data_fields.where(data_schema_id: DataSchema.find_by(key: 'additional_info').id).first_or_initialize(
        data: {named_date: teacher.named_date, occupation: teacher.occupation}
      ).save unless teacher.named_date.blank? && teacher.occupation.blank?
    end
  end

  task students_to_people: :environment do
    total = Student.count
    count = 0

    Student.find_each do |student|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Student Id: #{student.id}"

      person = student.person_id ? Person.find(student.person_id) : Person.new
      person.christian_name = student.christian_name
      person.name = student.full_name
      person.gender = student.gender
      person.birth_date = student.date_birth
      person.birth_place = student.place_birth
      person.save

      unless student.person_id
        student.person_id = person.id
        student.save
      end

      person.phones.where(primary: true).first_or_initialize(number: student.phone).save unless student.phone.blank?
      person.addresses.where(primary: true).first_or_initialize(
        street_number: student.street_number,
        street_name: student.street_name,
        ward: student.ward,
        district: student.district,
        area: student.area
      ).save unless student.street_name.blank?
      person.data_fields.where(data_schema_id: DataSchema.find_by(key: 'sacraments').id).first_or_initialize(
        data: {
          baptism_date: student.date_baptism,
          baptism_place: student.place_baptism,
          communion_date: student.date_communion,
          communion_place: student.place_communion,
          confirmation_date: student.date_confirmation,
          confirmation_place: student.place_confirmation,
          declaration_date: student.date_confirmation,
          declaration_place: student.place_confirmation
        }
      ).save unless [:date_baptism, :date_communion, :date_confirmation, :date_declaration].all? { |field| student.send(field).blank? }
      person.data_fields.where(data_schema_id: DataSchema.find_by(key: 'parents_info').id).first_or_initialize(
        data: {
          father_christian_name: student.date_baptism,
          father_name: student.father_full_name,
          father_phone: student.father_phone,
          mother_christian_name: student.mother_christian_name,
          mother_name: student.mother_full_name,
          mother_phone: student.mother_phone
        }
      ).save unless [
        :father_christian_name,
        :father_name,
        :father_phone,
        :mother_christian_name,
        :mother_name,
        :mother_phone
      ].all? { |field| student.send(field).blank? }
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