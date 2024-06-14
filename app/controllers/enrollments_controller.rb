# == Schema Information
#
# Table name: enrollments
#
#  id           :integer          not null, primary key
#  deleted_at   :datetime
#  result       :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  classroom_id :integer
#  person_id    :integer
#  student_id   :integer
#
# Indexes
#
#  index_enrollments_on_deleted_at  (deleted_at)
#  index_enrollments_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (classroom_id => classrooms.id)
#  fk_rails_...  (person_id => people.id)
#
class EnrollmentsController < SecondaryResourcesController
  before_action :admin?, except: %i[update]
  before_action :admin_or_teacher_of?, only: %i[update]

  def update
    skip_redirect
    super
  end

private

  def model_klass
    Enrollment
  end

  def permit_params
    [:result, :student_id, :classroom_id]
  end

  def admin_or_teacher_of?
    return if @current_user&.admin_or_teacher_of_enrollment?(model_klass.find(params[:id]), @current_year)
    flash[:warning] = 'Action not allowed.'
    redirect_back(fallback_location: root_path)
  end
end
