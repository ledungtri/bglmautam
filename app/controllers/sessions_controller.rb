class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:success] = "Logged in"
      redirect_to root_url
    else
      flash.now[:warning] = "Username or password is invalid"
      render "new"
    end
  end

  def create_teacher_session
    teacher = Teacher.find(params[:teacher_id])
    if teacher && teacher.authenticate(params[:password])
      session[:teacher_id] = teacher.id
      flash[:success] = "Logged in"
      redirect_to root_url
    else
      flash.now[:warning] = "Id or password is invalid"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:success] = "Logged out"
    redirect_to root_url
  end
end
