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

  def call_for_classroom(classroom)
    classroom_data(classroom)
  end

  private

  def classrooms
    @classrooms ||= Classroom.where(year: @year).sort_by(&:sort_param)
  end

  def academic_year_sundays
    @academic_year_sundays ||= begin
      year_start = Date.new(@year, 9, 1).then { |d| d + ((7 - d.wday) % 7) }
      year_end   = Date.new(@year + 1, 5, 31)
      (year_start..year_end).select(&:sunday?)
    end
  end

  def classroom_data(classroom)
    enrollments = preload_enrollments(classroom)
    active_count = enrollments.count { |e| ACTIVE_RESULTS.include?(e.result) }
    teaching_assignments = serialize(preload_teaching_assignments(classroom))

    {
      id: classroom.id,
      name: classroom.name,
      year: classroom.year,
      family: classroom.family,
      level: classroom.level,
      group: classroom.group,
      location: classroom.location,
      teaching_assignments: teaching_assignments,
      enrollments_overview: classroom.enrollments_overview,
      grade_counts: grade_counts(enrollments, active_count),
      evaluation_count: evaluation_count(enrollments, active_count),
      attendance_counts_by_week: attendance_by_week(enrollments, active_count)
    }
  end

  # `Enrollment`/`TeachingAssignment`'s default scope (`ClassroomRelationship`) unconditionally
  # adds `includes(:classroom).order('classrooms.year desc')` — meant for cross-classroom
  # listings (e.g. a person's history), not this per-classroom loop. Combined with
  # `.includes(:grades, :attendances, ...)` (two `has_many` at once), Rails eager-loads
  # everything through a single JOIN, fanning out into a grades × attendances cartesian
  # product per enrollment — tens of thousands of duplicate rows to deserialize for a single
  # classroom. The explicit preloader issues one simple batched query per association instead.
  def preload_enrollments(classroom)
    enrollments = classroom.enrollments.unscope(:includes, :order).to_a
    ActiveRecord::Associations::Preloader.new(records: enrollments, associations: [:grades, :attendances, :evaluation]).call
    enrollments
  end

  def preload_teaching_assignments(classroom)
    teaching_assignments = classroom.teaching_assignments.unscope(:includes, :order).to_a
    ActiveRecord::Associations::Preloader.new(
      records: teaching_assignments,
      # `teacher` is needed for `sort_param` even though the serializer never reads it.
      associations: [:person, :classroom, :evaluation, :attendances, :teacher]
    ).call
    teaching_assignments.sort_by(&:sort_param)
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

  def serialize(resource)
    ActiveModelSerializers::SerializableResource.new(resource).as_json
  end
end