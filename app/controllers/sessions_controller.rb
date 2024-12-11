class SessionsController < ApplicationController
  skip_before_action :auth

  def new
  end

  def create
    user = User.find_by_username(params[:username])

    unless user&.authenticate(params[:password])
      flash.now[:warning] = 'Username or password is invalid'
      return render 'new'
    end

    session[:user_id] = user&.id
    flash[:success] = 'Logged in'
    if user&.teacher
      classroom_id = Guidance.for_year(@current_year).where(teacher: user.teacher).pluck(:classroom_id).first
      return redirect_to classroom_url(classroom_id) if classroom_id
    end

    redirect_to root_url
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'Logged out'
    redirect_to root_url
  end
end
