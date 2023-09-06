class ApplicationController < ActionController::Base
  before_action :current_year
  before_action :admin?, only: [:admin]
  before_action :auth, only: [:search]

  def current_year
    @current_year = params[:year]&.to_i || 2023
    @current_year_long = "#{@current_year} - #{@current_year + 1}"
    @subject = 'Học với Chúa Giêsu để nối kết tình thương'
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def current_teacher
    @current_teacher ||= Teacher.find(session[:teacher_id]) if session[:teacher_id]
  end

  def auth
    redirect_to login_path unless current_user
  end

  def admin?
    return if current_user&.admin?

    flash[:warning] = 'Action not allowed. You are not an admin.'
    redirect_to :back || root_path
  end

  def admin
  end

  def search
    def titleize(string)
      mapping = {
        'á': 'Á', 'à': 'À', 'ả': 'Ả', 'ã': 'Ã', 'ạ': 'Ạ',
        'ă': 'Ă', 'ắ': 'Ắ', 'ặ': 'Ặ', 'ằ': 'Ằ', 'ẳ': 'Ẳ', 'ẵ': 'Ẵ',
        'â': 'Â', 'ấ': 'Ấ', 'ầ': 'Ầ', 'ẩ': 'Ẩ', 'ẫ': 'Ẫ', 'ậ': 'Ậ',
        'í': 'Í', 'ì': 'Ì', 'ỉ': 'Ỉ', 'ĩ': 'Ĩ', 'ị': 'Ị',
        'ú': 'Ú', 'ù': 'Ù', 'ủ': 'Ủ', 'ũ': 'Ũ', 'ụ': 'Ụ',
        'ư': 'Ư', 'ứ': 'Ứ', 'ừ': 'Ừ', 'ử': 'Ử', 'ữ': 'Ữ', 'ự': 'Ự',
        'é': 'É', 'è': 'È', 'ẻ': 'Ẻ', 'ẽ': 'Ẽ', 'ẹ': 'Ẹ',
        'ê': 'Ê', 'ế': 'Ế', 'ề': 'Ề', 'ể': 'Ể', 'ễ': 'Ễ', 'ệ': 'Ệ',
        'ó': 'Ó', 'ò': 'Ò', 'ỏ': 'Ỏ', 'õ': 'Õ', 'ọ': 'Ọ',
        'ô': 'Ô', 'ố': 'Ố', 'ồ': 'Ồ', 'ổ': 'Ổ', 'ỗ': 'Ỗ', 'ộ': 'Ộ',
        'ơ': 'Ơ', 'ớ': 'Ớ', 'ờ': 'Ờ', 'ở': 'Ở', 'ỡ': 'Ỡ', 'ợ': 'Ợ',
        'ý': 'Ý', 'ỳ': 'Ỳ', 'ỷ': 'Ỷ', 'ỹ': 'Ỹ', 'ỵ': 'Ỵ', 'đ': 'Đ'
      }

      return string unless string.class == String
      index = 0
      string = string.strip
      string.each_char.with_index do |char, i|
        replacement = mapping[char] || char.capitalize || char
        string[i] = replacement if i == index
        index = i + 1 if char == ' '
      end
    end

    @students = params[:query] ? Student.where('full_name like ?', "%#{titleize(params[:query])}%") : []
    @enrollments = @students&.map { |s| s.enrollments.last }

    @teachers = params[:query] ? Teacher.where('full_name like ?', "%#{titleize(params[:query])}%") : []
    @guidances = @teachers&.map { |t| t.guidances.last }
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
