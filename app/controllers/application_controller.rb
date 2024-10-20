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
    @enrollments = @students&.map { |s| s.enrollments.for_year(@current_year).first || s.enrollments.new(result: '') }.compact

    @teachers = params[:query] ? Teacher.where('full_name ILIKE ?', "%#{params[:query]}%") : []
    @guidances = @teachers&.map { |t| t.guidances.for_year(@current_year).first || t.guidances.new(position: '') }.compact
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

private
  def set_current_year
    @current_year = params[:year]&.to_i || 2024
    @current_year_long = "#{@current_year} - #{@current_year + 1}"
    @current_year_start_date = '2024.09.15'
    @current_year_end_date = '2025.06.15'
  end

  def set_current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end
end
