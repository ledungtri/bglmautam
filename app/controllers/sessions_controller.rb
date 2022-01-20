class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      session[:teacher_id] = user.teacher_id unless user.teacher_id.nil?
      flash[:success] = 'Logged in'
      redirect_to root_url
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
