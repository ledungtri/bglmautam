class UsersController < SecondaryResourcesController
  before_action :set_record, only: %i[admin_or_self?]
  before_action :admin?, except: %i[update]
  before_action :admin_or_self?, only: %i[update]

  def model_klass
    User
  end

  def permit_params
    [:username, :password, :password_confirmation, :teacher_id]
  end

  private

  def admin_or_self?
    return if @current_user&.admin_or_self?(@record)
    flash[:warning] = 'Action not allowed. You are not an admin.'
    redirect_back(fallback_location: root_path)
  end
end
