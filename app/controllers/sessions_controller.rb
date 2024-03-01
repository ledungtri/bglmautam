class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = 'Logged in'
      if user.teacher
        classroom_id = Guidance.for_year(@current_year).where(teacher: user.teacher).pluck(:classroom_id).first
        redirect_to classroom_url(classroom_id) if classroom_id
      else
        redirect_to root_url
      end
    else
      flash.now[:warning] = 'Username or password is invalid'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = 'Logged out'
    redirect_to root_url
  end
end
