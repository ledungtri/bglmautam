class TeachersController < ApplicationController
  before_action :set_teacher, only: [:show, :edit, :update, :destroy]
  before_action :auth 
  before_action :isAdmin, only: [:new, :create, :edit, :update, :destroy, :check]

  # GET /teachers
  # GET /teachers.json
  def index
    @teachers = Array.new
    
    cells = Cell.where(year: @current_year).sort_by {|cell| cell.sort_param}
    
    cells.each do |cell|
      @teachers = @teachers + cell.teachers
    end
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeachersPdf.new(@teachers, @current_year)
        send_data pdf.render, filename: "Danh Sách GLV Năm Học #{cells.first.long_year}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    @cells = @teacher.cells
    
    @years = Cell.all.map{|c| c.year}.uniq.sort{|x,y| -(x <=> y)}
    @opts = Array.new
    Cell.all.sort_by{|c| c.sort_param}.each do |cell|
      if cell.year == @years[0]
        @opts.push([cell.name, cell.id])
      end
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def teacher_params
      params.require(:teacher).permit(:christian_name, :full_name, :named_date, :date_birth, :occupation, :phone, :email, :street_number, :street_name, :ward, :district)
    end
end
