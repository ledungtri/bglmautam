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
    admin? || teacher_of_classroom?(classroom)
  end

  def teacher_of_classroom?(classroom)
    user.teacher&.teaching_assignments&.for_year(@current_year)&.map(&:classroom)&.include?(classroom)
  end

  def admin_or_self_teacher?(teacher)
    admin? || user == teacher.user
  end

  def admin_or_teacher_of_student?(student)
    admin_or_teacher_of_enrollment?(student.enrollments.for_year(@current_year)&.first)
  end

  def admin_or_teacher_of_enrollment?(enrollment)
    admin? || teacher_of_enrollment?(enrollment)
  end

  def teacher_of_enrollment?(enrollment)
    user.teacher&.teaching_assignments&.for_year(@current_year)&.map(&:classroom)&.include?(enrollment.classroom)
  end

  def admin_or_owner_of_person?(person)
    admin? || user.person == person
  end
end