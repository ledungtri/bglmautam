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
        flash[:success] = 'Student was successfully created.'
        format.html { redirect_to @student }
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
        flash[:success] = 'Student was successfully updated.'
        format.html { redirect_to @student }
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
      flash[:success] = 'Student was successfully destroyed.'
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  def check 
    student = Student.find(params[:student_id])
    student.checked = !student.checked
    student.save
    respond_to do |format|
      format.html { redirect_to :back}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:christian_name, :full_name, :gender, :phone, :date_birth, :place_birth, :date_baptism, :place_baptism, :date_communion, :place_communion, :date_confirmation, :place_confirmation, :date_declaration, :place_declaration, :street_number, :street_name, :ward, :district, :home_phone, :area, :father_christian_name, :father_full_name, :father_phone, :mother_christian_name, :mother_full_name, :mother_phone, :checked)
    end
end
