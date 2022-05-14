class StudentsController < ApplicationController
  before_action :set_student, only: %i[show edit update destroy]
  before_action :auth
  before_action :admin?, only: %i[new create destroy]
  before_action :admin_or_teacher?, only: %i[edit update]


  # GET /students
  # GET /students.json
  def index
    @attendances = Attendance.joins(:cell).where('cells.year = ?', @current_year).sort_by(&:sort_param)
  end

  # GET /students/1
  # GET /students/1.json
  def show
    @years = Cell.all.map(&:year).uniq.sort { |x, y| -(x <=> y) }
    @opts = []
    Cell.all.sort_by(&:sort_param).each do |cell|
      @opts.push([cell.name, cell.id]) if cell.year == @years[0] && cell.name != 'Trưởng Ban' && cell.name != 'Kỹ Thuật'
    end

    respond_to do |format|
      format.html
      format.pdf do
        pdf = StudentPdf.new(@student)
        send_data pdf.render, filename: "SYLL #{@student.name}.pdf", type: 'application/pdf', disposition: 'inline'
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
    @student.attendances.each(&:destroy)

    @student.destroy
    respond_to do |format|
      flash[:success] = 'Student was successfully destroyed.'
      format.html { redirect_to students_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  def admin_or_teacher?
    return if current_user&.admin?
    return if current_teacher&.cells.any? { |cell| @student.cells.include? cell }

    flash[:warning] = 'Action not allowed.'
    redirect_to :back || root_path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def student_params
    params.require(:student).permit(
      :christian_name,
      :full_name,
      :gender,
      :phone,
      :date_birth,
      :place_birth,
      :date_baptism,
      :place_baptism,
      :date_communion,
      :place_communion,
      :date_confirmation,
      :place_confirmation,
      :date_declaration,
      :place_declaration,
      :street_number,
      :street_name,
      :ward,
      :district,
      :home_phone,
      :area,
      :father_christian_name,
      :father_full_name,
      :father_phone,
      :mother_christian_name,
      :mother_full_name,
      :mother_phone
    )
  end
end
