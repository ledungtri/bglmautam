class ApplicationController < ActionController::Base
  before_action :set_current_year, :set_current_user
  before_action :auth, only: [:search]

  def auth
    redirect_to login_path unless @current_user
  end

  def admin?
    return if @current_user&.admin?

    flash[:warning] = 'Action not allowed. You are not an admin.'
    redirect_back(fallback_location: root_path)
  end

  def search
    @students = params[:query] ? Student.where('full_name ILIKE ?', "%#{params[:query]}%") : []
    @enrollments = @students&.map { |s| s.enrollments.last || s.enrollments.new(result: '') }.compact

    @teachers = params[:query] ? Teacher.where('full_name ILIKE ?', "%#{params[:query]}%") : [] # TODO: teacher
    @guidances = @teachers&.map { |t| t.guidances.last || t.guidances.new(position: '') }.compact # TODO: teacher
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private
  def set_current_year
    @current_year = params[:year]&.to_i || 2023
    @current_year_long = "#{@current_year} - #{@current_year + 1}"
    @current_year_start_date = '2023.09.10'
    @current_year_end_date = '2024.06.09'
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end
end
