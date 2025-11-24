# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  admin           :boolean          default(FALSE), not null
#  deleted_at      :datetime
#  password_digest :string           not null
#  username        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  person_id       :integer
#  teacher_id      :integer
#
# Indexes
#
#  index_users_on_deleted_at  (deleted_at)
#  index_users_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#
class UsersController < SecondaryResourcesController
   def index
    authorize User
    @teaching_assignments = TeachingAssignment.joins(:classroom).where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
  end

private

  def model_klass
    User
  end

  def permit_params
    [:username, :password, :password_confirmation, :teacher_id]
  end
end
