# frozen_string_literal: true

class ClassroomOverviewQuery
  ACTIVE_RESULTS = ['Đang Học', 'Lên Lớp'].freeze
  GRADE_TYPES = ['Giữa HK 1', 'Cuối HK 1', 'Giữa HK 2', 'Cuối HK 2'].freeze

  def initialize(year)
    @year = year.to_i
  end

  def call
    classrooms.map { |classroom| classroom_data(classroom) }
  end

  private

  def classrooms
    @classrooms ||= Classroom.where(year: @year).sort_by(&:sort_param)
  end

  def result_types
    @result_types ||= ResourceType.for_key('enrollment_result').pluck(:value)
  end

  def academic_year_sundays
    @academic_year_sundays ||= begin
      year_start = Date.new(@year, 9, 1).then { |d| d + ((7 - d.wday) % 7) }
      year_end   = Date.new(@year + 1, 5, 31)
      (year_start..year_end).select(&:sunday?)
    end
  end

  def classroom_data(classroom)
    enrollments = classroom.enrollments.includes(:grades, :attendances, :evaluation)
    active_count = enrollments.count { |e| ACTIVE_RESULTS.include?(e.result) }
    teaching_assignments = serialize(classroom.teaching_assignments.includes(:person).sort_by(&:sort_param))

    {
      id: classroom.id,
      name: classroom.name,
      year: classroom.year,
      family: classroom.family,
      level: classroom.level,
      group: classroom.group,
      location: classroom.location,
      teaching_assignments: teaching_assignments,
      enrollment_result_counts: result_counts(enrollments),
      grade_counts: grade_counts(enrollments, active_count),
      evaluation_count: evaluation_count(enrollments, active_count),
      attendance_counts_by_week: attendance_by_week(enrollments, active_count)
    }
  end

  def coverage_status(count, active_count)
    return nil if active_count == 0

    coverage = count.to_f / active_count
    if coverage >= 0.9 then 'good'
    elsif coverage >= 0.7 then 'medium'
    else 'bad'
    end
  end

  def grade_counts(enrollments, active_count)
    raw = enrollments.flat_map(&:grades).group_by(&:name).transform_values(&:count)
    GRADE_TYPES.each_with_object({}) do |type, h|
      count = raw[type] || 0
      h[type] = { count: count, status: coverage_status(count, active_count) }
    end
  end

  def evaluation_count(enrollments, active_count)
    count = enrollments.count { |e| e.evaluation.present? }
    { count: count, status: coverage_status(count, active_count) }
  end

  def attendance_by_week(enrollments, active_count)
    dates = enrollments.flat_map(&:attendances).map(&:date)
    academic_year_sundays.each_with_object({}) do |sunday, h|
      count = dates.count { |d| d == sunday }
      status = sunday > Date.today ? nil : coverage_status(count, active_count)
      h[sunday.to_s] = { count: count, status: status }
    end
  end

  def result_counts(enrollments)
    by_result = enrollments.group_by(&:result)
    result_types.each_with_object({}) do |type, h|
      h[type] = by_result[type]&.count || 0
    end
  end

  def serialize(resource)
    ActiveModelSerializers::SerializableResource.new(resource).as_json
  end
end