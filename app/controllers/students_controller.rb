class StudentsController < ApplicationController
  before_action :set_student, only: [:show, :edit, :update, :destroy]
  before_action :auth 
  
  # GET /students
  # GET /students.json
  def index
    dang_hoc = Array.new
    len_lop = Array.new
    hoc_lai = Array.new
    nghi_luon = Array.new
    chuyen_xu = Array.new
    
    cell_ids = Cell.where("year = ?", @current_year).pluck(:id)
    attendances = Attendance.where(cell_id: cell_ids)
    student_ids = attendances.pluck(:student_id)
    @students = Student.where(id: student_ids).sort_by {|student| student.sort_param}.each do |student|
      result = attendances.where(student_id: student.id).take.result
      case
      when result == "Đang Học"
        dang_hoc.push(student)
      when result == "Lên Lớp"
        len_lop.push(student)
      when result == "Học Lại"
        hoc_lai.push(student)
      when result == "Nghỉ Luôn"
        nghi_luon.push(student)
      when result == "Chuyển Xứ"
        chuyen_xu.push(student)
      end
    end

    @arrays = [hoc_lai, nghi_luon, chuyen_xu, dang_hoc, len_lop]

    respond_to do |format|
      format.html
      format.pdf do
        pdf = StudentsPdf.new(@arrays, @current_year)
        send_data pdf.render, filename: "Danh Sách Thiếu Nhi Năm Học #{@current_year.to_s + " - " + (@current_year+1).to_s}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @years = Cell.all.map{|c| c.year}.uniq.sort{|x,y| -(x <=> y)}
    @opts = Array.new
    Cell.all.sort_by{|c| c.sort_param}.each do |cell|
      if cell.year == @years[0] && cell.name != "Trưởng Ban" && cell.name != "Kỹ Thuật"
        @opts.push([cell.name, cell.id])
      end
    end
    
    respond_to do |format|
      format.html
      format.pdf do 
        pdf = StudentPdf.new(@student)
        send_data pdf.render , filename: "SYLL #{@student.name}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  # GET /students/new
  def new
    @student = Student.new
  end

  # GET /students/1/edit
  def edit
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        format.html { redirect_to @student, notice: 'Student was successfully created.' }
        format.json { render :show, status: :created, location: @student }
      else
        format.html { render :new }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to @student, notice: 'Student was successfully updated.' }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: 'Student was successfully destroyed.' }
      format.json { head :no_content }
    end
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
  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:christian_name, :full_name, :gender, :phone, :date_birth, :place_birth, :date_baptism, :place_baptism, :date_communion, :place_communion, :date_confirmation, :place_confirmation, :date_declaration, :place_declaration, :street_number, :street_name, :ward, :district, :home_phone, :area, :father_christian_name, :father_full_name, :father_phone, :mother_christian_name, :mother_full_name, :mother_phone)
    end
end
