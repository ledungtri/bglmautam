class ApplicationController < ActionController::Base
  before_action :current_year
  before_action :admin?, only: [:admin]
  before_action :auth, only: [:search]

  def current_year
    @current_year = 2020
    @current_year_long = "#{@current_year} - #{@current_year + 1}"
    @subject = 'Học với Chúa Giêsu xây dựng tương quan nối kết mọi người'
  end

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def current_teacher
    if session[:teacher_id]
      @current_teacher ||= Teacher.find(session[:teacher_id])
    else
      @current_teacher = nil
    end
  end

  def auth
    redirect_to login_path unless current_user
  end

  def admin?
    return if current_user&.isAdmin

    flash[:warning] = 'Action not allowed. You are not an admin.'
    redirect_to :back || root_path
  end

  def admin
  end

  def search
    @students = Student.where('full_name like ?', "%#{params[:student_name]}%") unless params[:student_name].nil?
    @teachers = Teacher.where('full_name like ?', "%#{params[:teacher_name]}%") unless params[:teacher_name].nil?
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
