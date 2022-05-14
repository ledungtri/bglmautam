class TeachersController < ApplicationController
  before_action :set_teacher, only: %i[show edit update destroy]
  before_action :auth
  before_action :admin?, only: %i[new create destroy]
  before_action :admin_or_self?, only: %i[edit update]

  # GET /teachers
  # GET /teachers.json
  def index
    @instructions = Instruction.joins(:cell).where('cells.year = ?', @current_year).sort_by(&:sort_param)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeachersPdf.new(@instructions, @current_year)
        send_data pdf.render, filename: "Danh Sách GLV Năm Học #{@current_year_long}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    @cells = @teacher.cells

    @years = Cell.all.map(&:year).uniq.sort { |x, y| -(x <=> y) }
    @opts = []
    Cell.all.sort_by(&:sort_param).each do |cell|
      @opts.push([cell.name, cell.id]) if cell.year == @years[0]
    end
  end

  # GET /teachers/new
  def new
    @teacher = Teacher.new
  end

  # GET /teachers/1/edit
  def edit
  end

  # POST /teachers
  # POST /teachers.json
  def create
    @teacher = Teacher.new(teacher_params)

    respond_to do |format|
      if @teacher.save
        flash[:success] = 'Teacher was successfully created.'
        format.html { redirect_to @teacher }
        format.json { render :show, status: :created, location: @teacher }
      else
        format.html { render :new }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /teachers/1
  # PATCH/PUT /teachers/1.json
  def update
    respond_to do |format|
      if @teacher.update(teacher_params)
        flash[:success] = 'Teacher was successfully updated.'
        format.html { redirect_to @teacher }
        format.json { render :show, status: :ok, location: @teacher }
      else
        format.html { render :edit }
        format.json { render json: @teacher.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /teachers/1
  # DELETE /teachers/1.json
  def destroy
    @teacher.instructions.each(&:destroy)

    @teacher.destroy
    respond_to do |format|
      flash[:success] = 'Teacher was successfully destroyed.'
      format.html { redirect_to teachers_url }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_teacher
    @teacher = Teacher.find(params[:id])
  end

  def admin_or_self?
    return if current_user&.admin? || current_user&.teacher_id == @teacher.id

    flash[:warning] = 'Action not allowed.'
    redirect_to :back || root_path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def teacher_params
    params.require(:teacher).permit(
      :christian_name,
      :full_name,
      :named_date,
      :date_birth,
      :occupation,
      :phone,
      :email,
      :street_number,
      :street_name,
      :ward,
      :district,
      :password,
      :password_confirmation,
      :is_admin
    )
  end
end
