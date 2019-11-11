class ApplicationController < ActionController::Base
  before_action :current_year
  
  def current_year
    @current_year = 2018
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
  
  def migrate 
    Student.delete_all
    @ids = Hash.new
    @unsaved = Array.new
    
    @students = Array.new
    File.open("#{Rails.root}/app/assets/students.txt").each { |line| @students << line.strip.split(/;/) }

    @students.each do |record|
      student = Student.new()
      
      student.christian_name = record[1]
      student.full_name = record[2]
      student.gender = record[3]
      student.phone = record[4]
      student.date_birth = record[5]
      student.place_birth = record[6]
      student.date_baptism = record[7]
      student.place_baptism = record[8]
      student.date_communion = record[9]
      student.place_communion = record[10]
      student.date_confirmation = record[11]
      student.place_confirmation = record[12]
      student.date_declaration = record[13]
      student.place_declaration = record[14]
      student.street_number = record[15]
      student.street_name = record[16]
      student.ward = record[17]
      student.district = record[18]
      student.area = record[19]
      student.home_phone = record[20]
      student.father_christian_name = record[21]
      student.father_full_name = record[22]
      student.father_phone = record[23]
      student.mother_christian_name = record[24]
      student.mother_full_name = record[25]
      student.mother_phone = record[26] 
      
      if student.save
        @ids[record[0]] = student.id
      else
        @unsaved.push(record[0])
      end
    end
      
    
    
    Cell.delete_all
    @class_id = Hash.new
    @class_unsaved = Array.new
      
    @classes = Array.new
    File.open("#{Rails.root}/app/assets/classes.txt").each { |line| @classes << line.strip.split(/;/) }
    
    @classes.each do |record|
      cell = Cell.new
        
        cell.year = record[1]
        cell.grade = record[2]
        cell.group = record[3]
        cell.location = record[4]
        
      if cell.save
        @class_id[record[0]] = cell.id
      else
        @class_unsaved.push(record[0])
      end
    end
    
    Teacher.delete_all
    @teacher_id = Hash.new
    @teacher_unsaved = Array.new
      
    @teachers = Array.new
    File.open("#{Rails.root}/app/assets/teachers.txt").each { |line| @teachers << line.strip.split(/;/) }
    
    @teachers.each do |record|
      teacher = Teacher.new
        
        teacher.christian_name = record[1]
        teacher.full_name = record[2]
        teacher.named_date = record[3]
        teacher.date_birth = record[4]
        teacher.occupation = record[5]
        teacher.phone = record[6]
        teacher.email = record[7]
        teacher.street_number = record[8]
        teacher.street_name = record[9]
        teacher.ward = record[10]
        teacher.district = record[11]
        
      if teacher.save
        @teacher_id[record[0]] = teacher.id
      else
        @teacher_unsaved.push(record[0])
      end
    end
    
    Attendance.delete_all
    @att_unsaved = Array.new
    
    @attendances = Array.new
    File.open("#{Rails.root}/app/assets/attendances.txt").each { |line| @attendances << line.strip.split(/;/) }
    
    @attendances.each do |record|
      
      codeClass = record[0]
      key = record[1]
      result = record[2]  
      
      att = Attendance.new
      
      att.student_id = @ids[key]
      att.cell_id = @class_id[codeClass]
      att.result = result
      
      if att.save
          
      else
        @att_unsaved.push([codeClass, key,@class_id[codeClass], @ids[key], result])
      end
    end
  
    Instruction.delete_all
    @ins_unsaved = Array.new
    
    @instructions = Array.new
    File.open("#{Rails.root}/app/assets/instructions.txt").each { |line| @instructions << line.strip.split(/;/) }
    
    @instructions.each do |record|
      
      codeClass = record[0]
      key = record[1]
      position = record[3]
      
      ins = Instruction.new
      
      ins.cell_id = @class_id[codeClass]
      ins.teacher_id = @teacher_id[key]
      ins.position = position
              
      if ins.save
          
      else
        @ins_unsaved.push([codeClass, key, @class_id[codeClass], @teacher_id[key], position])
      end
    end
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
