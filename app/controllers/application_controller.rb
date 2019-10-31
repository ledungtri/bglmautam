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

  def delete_wrong_mother_christian_name
    stu = Student.select { |s| s.father_christian_name? && s.mother_christian_name? && s.father_christian_name == s.mother_christian_name }
    stu.each do |student|
      f = student.father_christian_name 
      m = student.mother_christian_name 
      puts("father: " + f.to_s)
      puts("mother: " + m.to_s)

      puts("---------------------------")
    end
    puts Student.all.count
    puts stu.count
  end

  def temp_migrate_phone_number
    prefixes = {
      '0120' => '070',
      '0186' => '056',
      '0124' => '084',
      '0169' => '039',
      '0127' => '081',
      '0188' => '058',
      '0168' => '038',
      '0121' => '079',
      '0129' => '082',
      '0167' => '037',
      '0123' => '083',
      '0122' => '077',
      '0166' => '036',
      '0165' => '035',
      '0125' => '085',
      '0126' => '076',
      '0128' => '078',
      '0164' => '034',
      '0163' => '033',
      '0162' => '032',
      '0199' => '059'
    }

    @students = Student.all

    @students.each do |s|
      new_mPhone = s.mother_phone
      new_fPhone = s.father_phone

      prefixes.each {
        |old_prefix, new_prefix| 
        if s.mother_phone && s.mother_phone.start_with?(old_prefix) 
          new_mPhone[0,4] = new_prefix
        end
        if s.father_phone && s.father_phone.start_with?(old_prefix) 
          new_fPhone[0,4] = new_prefix
        end
      }
      s.update_attributes(:mother_phone => new_mPhone, :father_phone => new_fPhone)
      # update
    end
  end
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
