require 'csv'

namespace :import do
  # Usage: rails import:teacher_attendances CSV=/path/to/file.csv YEAR=2025
  task teacher_attendances: :environment do
    csv_path = ENV['CSV'] || Rails.root.join('tmp', 'teacher_attendances.csv')
    year     = ENV['YEAR']&.to_i || 2025
    dry_run  = ENV['DRY_RUN'] != 'false'

    puts dry_run ? "[DRY RUN] No records will be written." : "[LIVE RUN] Records will be saved."

    unless File.exist?(csv_path)
      puts "ERROR: CSV file not found at #{csv_path}"
      puts "Usage: rails import:teacher_attendances CSV=/path/to/file.csv YEAR=2025"
      exit 1
    end

    # Build classroom name → id lookup: "Khai Tâm A" → id
    # Classroom#name returns "#{family} #{level}#{group}".strip
    classroom_lookup = Classroom.where(year: year).index_by(&:name)

    # Build teacher name lookup: full_name → teacher, nickname → teacher
    teacher_by_full_name = Teacher.all.index_by { |t| "#{t.christian_name} #{t.full_name}".strip }
    teacher_by_nickname  = Teacher.all.index_by { |t| t.nickname.to_s.strip }

    stats = { created: 0, skipped: 0, errors: 0 }
    unmatched_classrooms = Set.new
    unmatched_teachers   = Set.new

    rows = CSV.read(csv_path, headers: true, encoding: 'UTF-8', skip_lines: /^,+$/)
              .reject { |row| row['Ngày vắng'].blank? || row['Lớp'].blank? || row['Tên Giáo Lý Viên'].blank? }

    puts "Processing #{rows.count} rows..."

    rows.each_with_index do |row, i|
      # --- Parse date ---
      begin
        date = Date.strptime(row['Ngày vắng'].strip, '%d/%m/%Y')
      rescue Date::Error
        puts "  [#{i + 2}] ERROR: invalid date '#{row['Ngày vắng']}'"
        stats[:errors] += 1
        next
      end

      # --- Look up classroom ---
      classroom_name = row['Lớp'].strip
      classroom = classroom_lookup[classroom_name]
      unless classroom
        unmatched_classrooms << classroom_name
        stats[:skipped] += 1
        next
      end

      # --- Look up teacher ---
      teacher_name = row['Tên Giáo Lý Viên'].strip
      nickname     = row['Tên Ngắn']&.strip
      teacher = teacher_by_full_name[teacher_name] || teacher_by_nickname[nickname.to_s]
      unless teacher
        unmatched_teachers << teacher_name
        stats[:skipped] += 1
        next
      end

      # --- Look up teaching assignment ---
      position = row['Phụ Trách']&.strip
      assignment = TeachingAssignment.find_by(teacher_id: teacher.id, classroom_id: classroom.id)
      unless assignment
        puts "  [#{i + 2}] SKIP: no teaching assignment for #{teacher_name} in #{classroom_name}"
        stats[:skipped] += 1
        next
      end

      # --- Skip if attendance already exists for this assignment + date ---
      if Attendance.exists?(attendable: assignment, date: date)
        stats[:skipped] += 1
        next
      end

      # --- Look up substitute teacher ---
      sub_name    = row['Tên Giáo Lý Viên dạy thế']&.strip
      sub_teacher = sub_name.present? ? (teacher_by_full_name[sub_name] || teacher_by_nickname[sub_name]) : nil

      # --- Build note from extra explanation columns ---
      note_parts = [
        row['Giải thích cụ thể hơn về lý do (nếu cần)'],
        row['Ghi chú khác (nếu cần)']
      ].map(&:presence).compact
      note = note_parts.join(' | ').presence

      # --- Create attendance ---
      unless dry_run
        Attendance.create!(
          attendable:             assignment,
          date:                   date,
          status:                 row['Vắng']&.strip,
          reason:                 row['Lý do vắng']&.strip.presence,
          substitute_teacher_id:  sub_teacher&.id,
          substitute_lesson:      row['Nội dung bài dạy thế']&.strip.presence,
          note:                   note
        )
      end

      stats[:created] += 1
    rescue => e
      puts "  [#{i + 2}] ERROR: #{e.message}"
      stats[:errors] += 1
    end

    puts "\n--- Done ---"
    puts "  Created : #{stats[:created]}"
    puts "  Skipped : #{stats[:skipped]}"
    puts "  Errors  : #{stats[:errors]}"

    unless unmatched_classrooms.empty?
      puts "\nUnmatched classrooms (check YEAR or spelling):"
      unmatched_classrooms.sort.each { |name| puts "  - #{name}" }
    end

    unless unmatched_teachers.empty?
      puts "\nUnmatched teachers (check full_name / nickname):"
      unmatched_teachers.sort.each { |name| puts "  - #{name}" }
    end
  end
end
