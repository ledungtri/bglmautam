class ApplicationController < ActionController::Base
  before_action :current_year, :subject
  
  def current_year
    @current_year = 2019
  end
  
  def subject 
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
  
  def new
    
  end
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
