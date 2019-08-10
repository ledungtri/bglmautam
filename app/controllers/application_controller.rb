class ApplicationController < ActionController::Base
  before_action :current_year
  
  def admin
    
  end

  
  def current_year
    @current_year = 2016
  end
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
