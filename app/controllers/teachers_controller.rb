class TeachersController < ApplicationController
  before_action :set_teacher, only: %i[show edit update destroy admin_or_self?]
  before_action :auth
  before_action :admin?, only: %i[new create destroy]
  before_action :admin_or_self?, only: %i[edit update]

  # GET /teachers
  # GET /teachers.json
  def index
    @guidances = Guidance.joins(:classroom).where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeachersPdf.new(@guidances, @current_year)
        send_data pdf.render, filename: "Danh Sách GLV Năm Học #{@current_year_long}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
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
      else
        format.html { render :new }
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
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /teachers/1
  # DELETE /teachers/1.json
  def destroy
    @teacher.guidances.each(&:destroy)

    @teacher.destroy
    respond_to do |format|
      flash[:success] = 'Teacher was successfully destroyed.'
      format.html { redirect_to teachers_url }
    end
  end

  def teachers_custom_export_view
  end

  def teachers_custom_export
    if params[:sort] == 'classroom'
      @guidances = Guidance.for_year(@current_year).sort_by(&:sort_param)
    else
      @guidances = Guidance.for_year(@current_year).sort_by { |g| g.teacher.sort_param }
    end

    pdf = TeachersCustomPdf.new(@guidances, params[:title], params[:page_layout].to_sym, params[:columns].split(','))
    send_data pdf.render, filename: "#{params[:title]}.pdf", type: 'application/pdf', disposition: 'inline'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_teacher
    @teacher = Teacher.find(params[:id])
  end

  def admin_or_self?
    return if @current_user&.admin_or_self_teacher?(@teacher)

    flash[:warning] = 'Action not allowed.'
    redirect_back(fallback_location: root_path)
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
      :district
    )
  end
end
