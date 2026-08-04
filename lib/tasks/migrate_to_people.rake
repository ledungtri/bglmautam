namespace :admin do
  task teachers_to_people: :environment do
    org = Organization.first
    abort 'ERROR: No organization found. Run Phase L seeding first.' unless org

    # Use unscoped to include soft-deleted teachers - active teaching_assignments
    # may still reference them
    total = Teacher.unscoped.count
    count = 0

    ActsAsTenant.with_tenant(org) do
      Teacher.unscoped.find_each do |teacher|
        puts '-----------------------------------------------'
        puts "Migrating #{count += 1}/#{total}..."
        puts "Teacher Id: #{teacher.id} (deleted: #{teacher.deleted_at.present?})"
        teacher.sync_person
        teacher.update_column(:person_id, teacher.person_id)
      end
    end
  end

  task students_to_people: :environment do
    org = Organization.first
    abort 'ERROR: No organization found. Run Phase L seeding first.' unless org

    # Use unscoped to include soft-deleted students
    total = Student.unscoped.count
    count = 0

    ActsAsTenant.with_tenant(org) do
      Student.unscoped.find_each do |student|
        puts '-----------------------------------------------'
        puts "Migrating #{count += 1}/#{total}..."
        puts "Student Id: #{student.id} (deleted: #{student.deleted_at.present?})"
        student.sync_person
        student.update_column(:person_id, student.person_id)
      end
    end
  end

  task teacher_person_id: :environment do
    # Use unscoped to include soft-deleted teachers - active teaching_assignments
    # may still reference them
    total = Teacher.unscoped.count
    count = 0

    Teacher.unscoped.find_each do |teacher|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Teacher Id: #{teacher.id} (deleted: #{teacher.deleted_at.present?})"

      # Skip if teacher has no person_id (means sync_person never ran or failed)
      if teacher.person_id.nil?
        puts "  SKIP - teacher.person_id is NULL (run admin:teachers_to_people first)"
        next
      end

      User.unscoped.where(teacher_id: teacher.id).update_all(person_id: teacher.person_id)
      TeachingAssignment.unscoped.where(teacher_id: teacher.id).update_all(person_id: teacher.person_id)
    end
  end

  task student_person_id: :environment do
    # Use unscoped to include soft-deleted students
    total = Student.unscoped.count
    count = 0

    Student.unscoped.find_each do |student|
      puts '-----------------------------------------------'
      puts "Migrating #{count += 1}/#{total}..."
      puts "Student Id: #{student.id} (deleted: #{student.deleted_at.present?})"

      # Skip if student has no person_id (means sync_person never ran or failed)
      if student.person_id.nil?
        puts "  SKIP - student.person_id is NULL (run admin:students_to_people first)"
        next
      end

      Enrollment.unscoped.where(student_id: student.id).update_all(person_id: student.person_id)
    end
  end

  desc 'Backfill NULL organization_id on orphaned Person records (Phase L/S prerequisite)'
  task backfill_person_organization_id: :environment do
    org = Organization.first
    abort 'ERROR: No organization found. Run Phase L seeding first.' unless org

    count = Person.unscoped.where(organization_id: nil).count
    if count.zero?
      puts 'OK - All Person records have organization_id set'
    else
      puts "Fixing #{count} Person records with NULL organization_id..."
      Person.unscoped.where(organization_id: nil).update_all(organization_id: org.id)
      puts "✅ Fixed #{count} records → organization_id: #{org.id} (#{org.name})"
    end
  end

  desc 'Audit person_id backfill coverage on enrollments/teaching_assignments before repointing FKs (Phase S step 5)'
  task audit_person_id_coverage: :environment do
    def report(label, count)
      puts "#{count.zero? ? 'OK' : 'FOUND'} - #{label}: #{count}"
    end

    puts '=== People (Prerequisites) ==='
    report('People with NULL organization_id', Person.unscoped.where(organization_id: nil).count)

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

  desc 'Soft-delete Student/Teacher rows with no enrollments/teaching_assignments (any linkage). DRY_RUN=false to actually delete.'
  task cleanup_orphaned_students_and_teachers: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    puts dry_run ? "[DRY RUN] No records will be deleted. Re-run with DRY_RUN=false to actually delete." : "[LIVE RUN] Matching records will be soft-deleted."

    def has_enrollment?(student)
      Enrollment.with_deleted.where(student_id: student.id).exists? ||
        (student.person_id.present? && Enrollment.with_deleted.where(person_id: student.person_id).exists?)
    end

    def has_teaching_assignment?(teacher)
      TeachingAssignment.with_deleted.where(teacher_id: teacher.id).exists? ||
        (teacher.person_id.present? && TeachingAssignment.with_deleted.where(person_id: teacher.person_id).exists?)
    end

    puts "\n=== Students with zero enrollments ==="
    student_count = 0
    Student.find_each do |student|
      next if has_enrollment?(student)

      person = student.person
      # Safety rail: never touch a row backing a real login, dry-run or not.
      if person&.user
        puts "SKIP student_id=#{student.id} person_id=#{student.person_id} name=#{person.name} — has a User account (#{person.user.username}), not orphaned data"
        next
      end

      student_count += 1
      puts "#{dry_run ? '[DRY RUN] would destroy' : 'destroying'} student_id=#{student.id} person_id=#{student.person_id} name=#{person&.name || student.full_name} created_at=#{student.created_at.to_date}"
      student.destroy unless dry_run
    end
    puts "Students #{dry_run ? 'that would be' : ''} destroyed: #{student_count}"

    puts "\n=== Teachers with zero teaching_assignments ==="
    teacher_count = 0
    Teacher.find_each do |teacher|
      next if has_teaching_assignment?(teacher)

      person = teacher.person
      if person&.user
        puts "SKIP teacher_id=#{teacher.id} person_id=#{teacher.person_id} name=#{person.name} — has a User account (#{person.user.username}), not orphaned data"
        next
      end

      teacher_count += 1
      puts "#{dry_run ? '[DRY RUN] would destroy' : 'destroying'} teacher_id=#{teacher.id} person_id=#{teacher.person_id} name=#{person&.name || teacher.full_name} created_at=#{teacher.created_at.to_date}"
      teacher.destroy unless dry_run
    end
    puts "Teachers #{dry_run ? 'that would be' : ''} destroyed: #{teacher_count}"
  end

  desc 'Soft-delete Person rows with no enrollments/teaching_assignments ever. DRY_RUN=false to actually delete.'
  task cleanup_orphaned_people: :environment do
    dry_run = ENV['DRY_RUN'] != 'false'
    puts dry_run ? "[DRY RUN] No records will be deleted. Re-run with DRY_RUN=false to actually delete." : "[LIVE RUN] Matching records will be soft-deleted."

    # Teacher rows referenced as a substitute on some Attendance are meaningfully
    # still in use even with zero teaching_assignments of their own — never touch those.
    substitute_teacher_ids = Attendance.with_deleted.where.not(substitute_teacher_id: nil).distinct.pluck(:substitute_teacher_id)

    def has_activity?(person_id)
      Enrollment.with_deleted.where(person_id: person_id).exists? ||
        TeachingAssignment.with_deleted.where(person_id: person_id).exists?
    end

    # Only counts as a safe duplicate if that other record actually has real
    # activity — otherwise two mutually-orphaned copies would "vouch" for each
    # other and both get destroyed, losing the person from the system entirely.
    def active_duplicate_for(person)
      Person.where(name: person.name, birth_date: person.birth_date).where.not(id: person.id)
            .find { |candidate| has_activity?(candidate.id) }
    end

    def orphaned_sibling_ids(person)
      Person.where(name: person.name, birth_date: person.birth_date).where.not(id: person.id).pluck(:id)
    end

    count = 0
    with_active_duplicate = 0
    without_any_duplicate = 0
    cluster_count = 0
    Person.find_each do |person|
      next if has_activity?(person.id)

      if person.user
        puts "SKIP person_id=#{person.id} name=#{person.name} — has a User account (#{person.user.username}), not orphaned data"
        next
      end

      teacher = person.teacher
      if teacher && substitute_teacher_ids.include?(teacher.id)
        puts "SKIP person_id=#{person.id} name=#{person.name} — teacher_id=#{teacher.id} is referenced as a substitute teacher on an Attendance"
        next
      end

      active_dup = active_duplicate_for(person)
      if active_dup
        with_active_duplicate += 1
        count += 1
        puts "#{dry_run ? '[DRY RUN] would destroy' : 'destroying'} person_id=#{person.id} name=#{person.name} birth_date=#{person.birth_date} created_at=#{person.created_at.to_date} " \
             "— DUPLICATE of genuinely-active person_id=#{active_dup.id} (has a real enrollment/teaching_assignment)"
        teacher&.destroy unless dry_run
        person.student&.destroy unless dry_run
        person.destroy unless dry_run
        next
      end

      siblings = orphaned_sibling_ids(person)
      if siblings.any?
        cluster_count += 1
        puts "CLUSTER (NOT auto-deleting, needs manual review) person_id=#{person.id} name=#{person.name} birth_date=#{person.birth_date} created_at=#{person.created_at.to_date} " \
             "— #{siblings.size} other orphaned duplicate(s) with the same name+dob (ids: #{siblings.join(', ')}), none has any real enrollment/teaching_assignment"
        next
      end

      without_any_duplicate += 1
      count += 1
      puts "#{dry_run ? '[DRY RUN] would destroy' : 'destroying'} person_id=#{person.id} name=#{person.name} birth_date=#{person.birth_date} created_at=#{person.created_at.to_date} " \
           "(live teacher=#{!!teacher} live student=#{!!person.student}) — NO duplicate at all — would be the only record of this person"
      next if dry_run

      teacher&.destroy
      person.student&.destroy
      person.destroy
    end
    puts "People #{dry_run ? 'that would be' : ''} destroyed: #{count} (#{with_active_duplicate} with a genuinely-active duplicate, #{without_any_duplicate} with no duplicate at all)"
    puts "People flagged as mutual-orphan clusters, left untouched: #{cluster_count}"
  end

  desc 'Audit for duplicate/colliding User accounts. Read-only, never deletes anything.'
  task audit_duplicate_users: :environment do
    puts "=== Duplicate usernames (same username, 2+ User rows) ==="
    dupes = User.unscoped.group(:username).having('count(*) > 1').count
    if dupes.empty?
      puts 'OK - none found'
    else
      dupes.each do |username, n|
        puts "\nusername=#{username} (#{n} accounts)"
        User.unscoped.where(username: username).find_each do |u|
          person = u.person
          puts "  user_id=#{u.id} deleted_at=#{u.deleted_at.inspect} admin=#{u.admin} " \
               "person_id=#{u.person_id} person_name=#{person&.name} person_birth_date=#{person&.birth_date} " \
               "person_deleted_at=#{person&.deleted_at.inspect} created_at=#{u.created_at.to_date}"
        end
      end
    end

    puts "\n=== One person_id with more than one User row (has_one :user violated) ==="
    person_id_dupes = User.unscoped.group(:person_id).having('count(*) > 1').count.except(nil)
    if person_id_dupes.empty?
      puts 'OK - none found'
    else
      person_id_dupes.each_key do |person_id|
        person = Person.find_by(id: person_id)
        puts "\nperson_id=#{person_id} name=#{person&.name}"
        User.unscoped.where(person_id: person_id).find_each do |u|
          puts "  user_id=#{u.id} username=#{u.username} deleted_at=#{u.deleted_at.inspect} admin=#{u.admin} created_at=#{u.created_at.to_date}"
        end
      end
    end

    puts "\n=== Different Person records (same name+birth_date), each with their own separate User ==="
    # Distinct from both checks above: each of these has a *different* person_id and
    # may have its own unique username, but they're duplicate Person records for what
    # looks like the same real individual, each with its own separate working login.
    person_ids_with_user = Person.joins(:user).distinct.pluck(:id)
    groups = Person.where(id: person_ids_with_user).group(:name, :birth_date).having('count(*) > 1').count
    if groups.empty?
      puts 'OK - none found'
    else
      groups.each_key do |name, birth_date|
        puts "\nname=#{name} birth_date=#{birth_date}"
        Person.where(name: name, birth_date: birth_date, id: person_ids_with_user).find_each do |person|
          u = person.user
          puts "  person_id=#{person.id} person_created_at=#{person.created_at.to_date} " \
               "user_id=#{u.id} username=#{u.username} admin=#{u.admin} user_created_at=#{u.created_at.to_date}"
        end
      end
    end
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