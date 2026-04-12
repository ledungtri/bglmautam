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

    # Validate attendance statuses exist as resource types
    valid_statuses = ResourceType.where(key: 'attendance_status').pluck(:value).to_set
    puts "Known attendance statuses: #{valid_statuses.to_a.join(', ')}"

    # Build teacher lookup: limited to teachers with assignments in classrooms for the given year
    # (including soft-deleted assignments)
    teachers = Teacher.joins("INNER JOIN teaching_assignments ON teaching_assignments.teacher_id = teachers.id")
                      .joins("INNER JOIN classrooms ON classrooms.id = teaching_assignments.classroom_id")
                      .where(classrooms: { year: year, deleted_at: nil })
                      .distinct
    teacher_by_full_name = teachers.index_by { |t| "#{t.christian_name} #{t.full_name}".strip }
    teacher_by_nickname  = teachers.index_by { |t| t.nickname.to_s.strip }

    stats = { created: 0, duplicate: 0, errors: 0 }
    unknown_statuses = Set.new

    all_rows = CSV.read(csv_path, headers: true, encoding: 'UTF-8', skip_lines: /^,+$/)
    incomplete = all_rows.count { |row| row['Ngày vắng'].blank? || row['Tên Giáo Lý Viên'].blank? }
    rows = all_rows.reject { |row| row['Ngày vắng'].blank? || row['Tên Giáo Lý Viên'].blank? }

    puts "Processing #{rows.count} rows (#{incomplete} incomplete rows skipped)..."
    puts

    rows.each_with_index do |row, i|
      line = i + 2

      # --- Parse date ---
      begin
        date = Date.strptime(row['Ngày vắng'].strip, '%d/%m/%Y')
      rescue Date::Error
        puts "  [#{line}] ERROR: invalid date '#{row['Ngày vắng']}'"
        stats[:errors] += 1
        next
      end

      # --- Check attendance status ---
      status = row['Vắng']&.strip
      if status.present? && !valid_statuses.include?(status)
        unknown_statuses << status
      end

      # --- Look up teacher ---
      teacher_name = row['Tên Giáo Lý Viên'].strip
      nickname     = row['Tên Ngắn']&.strip
      teacher = teacher_by_full_name[teacher_name] || teacher_by_nickname[nickname.to_s]
      unless teacher
        puts "  [#{line}] ERROR: teacher not found '#{teacher_name}'"
        stats[:errors] += 1
        next
      end

      # --- Find teaching assignment for year, fall back to last deleted ---
      assignment = TeachingAssignment
                     .joins(:classroom)
                     .where(teacher_id: teacher.id, classrooms: { year: year })
                     .first

      unless assignment
        assignment = TeachingAssignment
                       .with_deleted
                       .joins(:classroom)
                       .where(teacher_id: teacher.id, classrooms: { year: year })
                       .order(deleted_at: :desc)
                       .first
        if assignment
          puts "  [#{line}] WARN: using deleted assignment for '#{teacher_name}' (deleted #{assignment.deleted_at&.to_date})"
        else
          puts "  [#{line}] ERROR: no assignment found for '#{teacher_name}' in year #{year}"
          stats[:errors] += 1
          next
        end
      end

      # --- Skip duplicates ---
      if Attendance.with_deleted.exists?(attendable: assignment, date: date)
        stats[:duplicate] += 1
        next
      end

      # --- Look up substitute teacher ---
      sub_name    = row['Tên Giáo Lý Viên dạy thế']&.strip
      sub_teacher = sub_name.present? ? (teacher_by_full_name[sub_name] || teacher_by_nickname[sub_name]) : nil
      if sub_name.present? && sub_teacher.nil?
        puts "  [#{line}] WARN: substitute teacher not found '#{sub_name}', importing without substitute"
      end

      # --- Build note ---
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
          status:                 status,
          reason:                 row['Lý do vắng']&.strip.presence,
          substitute_teacher_id:  sub_teacher&.id,
          substitute_lesson:      row['Nội dung bài dạy thế']&.strip.presence,
          note:                   note
        )
      end

      stats[:created] += 1
    rescue => e
      puts "  [#{line}] ERROR: #{e.message}"
      stats[:errors] += 1
    end

    puts
    puts "--- Done ---"
    puts "  Created    : #{stats[:created]}"
    puts "  Duplicates : #{stats[:duplicate]}"
    puts "  Errors     : #{stats[:errors]}"

    unless unknown_statuses.empty?
      puts "\nUnknown attendance statuses (add to resource_types):"
      unknown_statuses.sort.each { |s| puts "  - #{s}" }
    end
  end
end