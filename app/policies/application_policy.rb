class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
    @current_year = 2023
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

  def admin_or_self_teacher?(teacher)
    admin? || user == teacher.user
  end

  def admin_or_teacher_of_student?(student, year = @current_year)
    admin_or_teacher_of_enrollment?(student.enrollments.for_year(year)&.first, year)
  end

  def admin_or_teacher_of_enrollment?(enrollment, year = @current_year)
    admin? || teacher_of_enrollment?(enrollment, year)
  end

  def teacher_of_enrollment?(enrollment, year = @current_year)
    enrollment.classroom == user.teacher&.guidances&.for_year(year)&.first&.classroom
  end
end