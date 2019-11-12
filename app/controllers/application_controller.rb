class ApplicationController < ActionController::Base
  before_action :current_year
  
  def current_year
    @current_year = 2019
    @subject = "Học với Chúa Giêsu để sống sự thật"
  end
  
  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end
  
  def auth 
    if !current_user
      redirect_to login_path
    end
  end
  
  def admin
  end
  
  def searchByName
    if !params[:student_name].nil?
      @students = Student.where("full_name like ?", "%#{params[:student_name]}%")
    end
    if !params[:teacher_name].nil?
      @teachers = Teacher.where("full_name like ?", "%#{params[:teacher_name]}%")
    end
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
