class ApplicationPolicy
  attr_reader :user, :record

  def initialize(context, record)
    @user = context.user
    @record = record
    @current_year = context.current_year
  end

  def index?
    true
  end

  def show?
    true
  end

  def search?
    true
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

private

  def admin?
    user&.admin?
  end

  def admin_or_self?(user_record)
    admin? || user == user_record
  end

  def admin_or_teacher_of_classroom?(classroom)
    admin? || assigned_classrooms.include?(classroom)
  end

  def admin_or_self_teacher?(teacher)
    admin? || user == teacher.user
  end

  def admin_or_teacher_of_student?(student)
    admin_or_teacher_of_enrollment?(student.person.enrollments.for_year(@current_year)&.first)
  end

  def admin_or_teacher_of_enrollment?(enrollment)
    admin? || assigned_classrooms.include?(enrollment.classroom)
  end

  def admin_or_teacher_of_teaching_assignment?(teaching_assignment)
    admin? || assigned_classrooms.include?(teaching_assignment.classroom)
  end

  # Classrooms `user` is assigned to teach this year, resolved via Person (not Teacher) —
  # the single source of truth every admin_or_teacher_of_* predicate above checks against.
  def assigned_classrooms
    @assigned_classrooms ||= user&.person&.teaching_assignments&.for_year(@current_year)&.map(&:classroom) || []
  end

end