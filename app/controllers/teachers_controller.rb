# == Schema Information
#
# Table name: teachers
#
#  id             :integer          not null, primary key
#  christian_name :string
#  date_birth     :date
#  deleted_at     :datetime
#  district       :string
#  email          :string
#  full_name      :string
#  gender         :string
#  named_date     :string
#  nickname       :string
#  occupation     :string
#  phone          :string
#  street_name    :string
#  street_number  :string
#  ward           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  person_id      :integer
#
# Indexes
#
#  index_teachers_on_deleted_at  (deleted_at)
#
class TeachersController < ApplicationController
  before_action :set_teacher, only: %i[show update destroy admin_or_self?]

  # GET /teachers
  # GET /teachers.json
  def index
    authorize Teacher
    @guidances = Guidance.joins(:classroom).where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = TeachersPdf.new(@guidances, @current_year)
        send_data pdf.render,
                  filename: "Danh Sách GLV Năm Học #{@current_year_long}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  # GET /teachers/1
  # GET /teachers/1.json
  def show
    authorize @teacher
  end

  # GET /teachers/new
  def new
    authorize Teacher

    @teacher = Teacher.new
    render :show
  end

  # POST /teachers
  # POST /teachers.json
  def create
    authorize Teacher

    @teacher = Teacher.new(teacher_params)

    respond_to do |format|
      if @teacher.save
        flash[:success] = 'Teacher was successfully created.'
        format.html { redirect_to @teacher }
      else
        format.html { render :show }
      end
    end
  end

  # PATCH/PUT /teachers/1
  # PATCH/PUT /teachers/1.json
  def update
    authorize @teacher

    respond_to do |format|
      if @teacher.update(teacher_params)
        flash[:success] = 'Teacher was successfully updated.'
        format.html { redirect_to @teacher }
      else
        format.html { render :show }
      end
    end
  end

  # DELETE /teachers/1
  # DELETE /teachers/1.json
  def destroy
    authorize @teacher

    @teacher.guidances.each(&:destroy)

    @teacher.destroy
    respond_to do |format|
      flash[:success] = 'Teacher was successfully destroyed.'
      format.html { redirect_to teachers_url }
    end
  end

  def teachers_custom_export_form
    authorize Teacher, :index?

    render 'custom_export/form', locals: { title: 'Giáo Lý Viên', path: teachers_custom_export_path }
  end

  def teachers_custom_export
    authorize Teacher, :index?

    @guidances = Guidance.for_year(@current_year).sort_by(&:sort_param)

    pdf = TeachersCustomPdf.new(@guidances, params[:title], params[:page_layout].to_sym, params[:columns].split(','))
    send_data pdf.render, filename: "#{params[:title]}.pdf", type: 'application/pdf', disposition: 'inline'
  end

  def attendances
    authorize Guidance, :update?
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_teacher
    @teacher = Teacher.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def teacher_params
    params.require(:teacher).permit(
      :christian_name,
      :full_name,
      :nickname,
      :date_birth,
      :gender,
      :phone,
      :email,
      :street_number,
      :street_name,
      :ward,
      :district,
      :named_date,
      :occupation
    )
  end
end
