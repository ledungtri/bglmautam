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
#  teacher_id      :integer
#
# Indexes
#
#  index_users_on_deleted_at  (deleted_at)
#
class UsersController < SecondaryResourcesController
  before_action :admin?, except: %i[update]
  before_action :admin_or_self?, only: %i[update]

private

  def model_klass
    User
  end

  def permit_params
    [:username, :password, :password_confirmation, :teacher_id]
  end

  def admin_or_self?
    return if @current_user&.admin_or_self?(model_klass.find(params[:id]))
    flash[:warning] = 'Action not allowed. You are not an admin.'
    redirect_back(fallback_location: root_path)
  end
end
