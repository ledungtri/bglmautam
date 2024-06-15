namespace :admin do
  task teachers_to_people: :environment do
    total = Teacher.count
    count = 0

    Teacher.find_each do |teacher|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Teacher Id: #{teacher.id}"

      attributes = teacher.attributes
      attributes.delete 'id'
      attributes.delete 'person_id'
      attributes['name'] = attributes.delete 'full_name'
      attributes['birth_date'] = attributes.delete 'date_birth'

      phone_number = attributes.delete 'phone'
      email_address = attributes.delete 'email'
      named_date = attributes.delete 'named_date'
      occupation = attributes.delete 'occupation'

      street_number = attributes.delete 'street_number'
      street_name = attributes.delete 'street_name'
      ward = attributes.delete 'ward'
      district = attributes.delete 'district'

      person = Person.create(attributes)
      teacher.person_id = person.id
      teacher.save

      unless phone_number.blank?
        phone = person.phones.first_or_initialize(primary: true)
        phone.number = phone_number
        phone.save
      end

      unless email_address.blank?
        email = person.emails.first_or_initialize(primary: true)
        email.address = email_address
        email.save
      end

      unless street_name.blank?
        address = person.addresses.first_or_initialize(primary: true)
        address.street_number = street_number
        address.street_name = street_name
        address.ward = ward
        address.district = district
        address.save
      end

      unless named_date.blank? && occupation.blank?
        data_schema = DataSchema.find_by(key: 'additional_info')
        data_field = person.data_fields.first_or_initialize(data_schema_id: data_schema.id)
        data_field.data = { named_date: named_date, occupation: occupation }
        data_field.save
      end
    end
  end

  task students_to_people: :environment do
    total = Student.count
    count = 0

    Student.find_each do |student|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Student Id: #{student.id}"

      attributes = student.attributes
      attributes.delete 'id'
      attributes.delete 'person_id'
      attributes['name'] = attributes.delete 'full_name'
      attributes['birth_date'] = attributes.delete 'date_birth'
      attributes['birth_place'] = attributes.delete 'place_birth'

      phone_number = attributes.delete 'phone'

      street_number = attributes.delete 'street_number'
      street_name = attributes.delete 'street_name'
      ward = attributes.delete 'ward'
      district = attributes.delete 'district'
      area = attributes.delete 'area'

      sacraments = {
        baptism_date: attributes.delete('date_baptism'),
        baptism_place: attributes.delete('place_baptism'),
        communion_date: attributes.delete('date_communion'),
        communion_place: attributes.delete('place_communion'),
        confirmation_date: attributes.delete('date_confirmation'),
        confirmation_place: attributes.delete('place_confirmation'),
        declaration_date: attributes.delete('date_declaration'),
        declaration_place: attributes.delete('place_declaration')
      }

      parents_info = {
        father_christian_name: attributes.delete('father_christian_name'),
        father_name: attributes.delete('father_full_name'),
        father_phone: attributes.delete('father_phone'),
        mother_christian_name: attributes.delete('mother_christian_name'),
        mother_name: attributes.delete('mother_full_name'),
        mother_phone: attributes.delete('mother_phone')
      }

      person = Person.create(attributes)
      student.person_id = person.id
      student.save

      unless phone_number.blank?
        phone = person.phones.first_or_initialize(primary: true)
        phone.number = phone_number
        phone.save
      end

      unless street_name.blank?
        address = person.addresses.first_or_initialize(primary: true)
        address.street_number = street_number
        address.street_name = street_name
        address.ward = ward
        address.district = district
        address.area = area
        address.save
      end

      unless sacraments.values.all? { |value| value.blank? }
        data_schema = DataSchema.find_by(key: 'sacraments')
        data_field = person.data_fields.first_or_initialize(data_schema_id: data_schema.id)
        data_field.data = sacraments
        data_field.save
      end

      unless parents_info.values.all? { |value| value.blank? }
        data_schema = DataSchema.find_by(key: 'parents_info')
        data_field = person.data_fields.first_or_initialize(data_schema_id: data_schema.id)
        data_field.data = parents_info
        data_field.save
      end
    end
  end

  task teacher_person_id: :environment do
    total = Teacher.count
    count = 0

    Teacher.find_each do |teacher|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Teacher Id: #{teacher.id}"

      user = teacher.user
      if user
        user.person_id = teacher.person_id
        user.save
      end

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