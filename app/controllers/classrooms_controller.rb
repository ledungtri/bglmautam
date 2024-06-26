# == Schema Information
#
# Table name: classrooms
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  family     :string
#  group      :string
#  level      :integer
#  location   :string
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_classrooms_on_deleted_at  (deleted_at)
#
class ClassroomsController < ApplicationController
  before_action :set_classroom, only: %i[show update destroy custom_export_form custom_export]
  before_action :auth
  before_action :admin?, only: %i[new create update destroy]

  # GET /classrooms
  # GET /classrooms.json
  def index
    @classrooms = Classroom.where(year: @current_year).where(family: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời']).sort_by(&:sort_param)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = ClassroomsPdf.new(@classrooms)
        send_data pdf.render, filename: "Thống Kê Các Lớp Năm Học #{@classrooms.first.long_year}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /classrooms/1
  # GET /classrooms/1.json
  def show
    @guidances = @classroom.guidances.sort_by(&:sort_param)
    @enrollments = @classroom.enrollments.sort_by(&:sort_param)
    respond_to do |format|
      format.html
      format.pdf do
        if params[:style] == 'teachers_contact'
          pdf = TeachersContactPdf.new(@classroom)
          return send_data pdf.render, filename: "SĐT GLV.pdf", type: 'application/pdf', disposition: 'inline'
        end

        pdfClass = params[:style] == 'compact' ? CompactStudentsPdf : StudentsPdf
        pdf = pdfClass.new(@enrollments, "Danh Sách Lớp #{@classroom.name}\nNăm Học #{@classroom.long_year}")
        send_data pdf.render, filename: "Danh Sách Lớp #{@classroom.name} Năm Học #{@classroom.long_year}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /classrooms/new
  def new
    @classroom = Classroom.new
    render :show
  end

  # POST /classrooms
  # POST /classrooms.json
  def create
    @classroom = Classroom.new(classroom_params)

    respond_to do |format|
      if @classroom.save
        flash[:success] = 'Classroom was successfully created.'
        format.html { redirect_to @classroom }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /classrooms/1
  # PATCH/PUT /classrooms/1.json
  def update
    respond_to do |format|
      if @classroom.update(classroom_params)
        flash[:success] = 'Classroom was successfully updated.'
        format.html { redirect_to @classroom }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /classrooms/1
  # DELETE /classrooms/1.json
  def destroy
    @classroom.guidances.each(&:destroy)

    @classroom.enrollments.each(&:destroy)

    @classroom.destroy
    respond_to do |format|
      flash[:success] = 'Classroom was successfully destroyed.'
      format.html { redirect_to classrooms_url }
    end
  end

  def students_personal_details
    @classroom = Classroom.find(params[:classroom_id])
    @students = Student.in_classroom(@classroom).sort_by(&:sort_param)

    respond_to do |format|
      format.html

      format.pdf do
        pdf = StudentsPersonalDetailsPdf.new(@students)
        send_data pdf.render,
                  filename: "Sơ Yếu Lý Lịch Lớp #{@classroom.name} Năm Học #{@classroom.long_year}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def classrooms_custom_export_form
    render 'custom_export/form', locals: { title: 'Lớp Học', path: classrooms_custom_export_path }
  end

  def classrooms_custom_export
    @classrooms = Classroom.where(year: @current_year).where(family: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời']).sort_by(&:sort_param)
    pdf = ClassroomsCustomPdf.new(@classrooms, params[:title], params[:page_layout].to_sym, params[:columns].split(','))
    send_data pdf.render,
              filename: "#{params[:title]}.pdf",
              type: 'application/pdf',
              disposition: 'inline'
  end

  def custom_export_form
    render 'custom_export/form', locals: { title: @classroom.name, path: classroom_custom_export_path(@classroom) }
  end

  def custom_export
    pdf = CustomStudentsPdf.new(@classroom, params[:title], params[:page_layout].to_sym, params[:columns].split(','))
    send_data pdf.render, filename: "#{@classroom.name} - #{params[:title]}.pdf", type: 'application/pdf', disposition: 'inline'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_classroom
    @classroom = Classroom.find(params[:id] || params[:classroom_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def classroom_params
    params.require(:classroom).permit(:year, :family, :level, :group, :location)
  end
end
