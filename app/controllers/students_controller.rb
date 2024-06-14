# == Schema Information
#
# Table name: students
#
#  id                    :integer          not null, primary key
#  area                  :string
#  christian_name        :string
#  date_baptism          :date
#  date_birth            :date
#  date_communion        :date
#  date_confirmation     :date
#  date_declaration      :date
#  deleted_at            :datetime
#  district              :string
#  father_christian_name :string
#  father_full_name      :string
#  father_phone          :string
#  full_name             :string
#  gender                :string
#  mother_christian_name :string
#  mother_full_name      :string
#  mother_phone          :string
#  phone                 :string
#  place_baptism         :string
#  place_birth           :string
#  place_communion       :string
#  place_confirmation    :string
#  place_declaration     :string
#  street_name           :string
#  street_number         :string
#  ward                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  person_id             :integer
#
# Indexes
#
#  index_students_on_deleted_at  (deleted_at)
#
class StudentsController < ApplicationController
  before_action :set_student, only: %i[show update destroy admin_or_teacher?]
  before_action :auth
  before_action :admin?, only: %i[new create destroy]
  before_action :admin_or_teacher?, only: %i[update]

  # GET /students
  # GET /students.json
   def index
     @enrollments = Enrollment.where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
  
     respond_to do |format|
       format.html
       format.pdf do
         if params[:style] == 'empty'
           pdf = StudentPdf.new(Student.new)
           send_data pdf.render, filename: "SYLL.pdf", type: 'application/pdf', disposition: 'inline'
         else
           pdf = StudentsPdf.new(@enrollments, "Danh Sách Thiếu Nhi\nNăm Học #{@current_year_long}")
           send_data pdf.render, filename: "Danh Sách Thiếu Nhi Năm Học #{@current_year_long}.pdf", type: 'application/pdf', disposition: 'inline'
         end
       end
     end
   end

  # GET /students/1
  # GET /students/1.json
  def show
    @years = Classroom.all.map(&:year).uniq.sort { |x, y| -(x <=> y) }
    @opts = []
    Classroom.all.sort_by(&:sort_param).each do |classroom|
      @opts.push([classroom.name, classroom.id]) if classroom.year == @years[0] && classroom.name != 'Trưởng Ban' && classroom.name != 'Kỹ Thuật'
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
    render :show
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)

    respond_to do |format|
      if @student.save
        flash[:success] = 'Student was successfully created.'
        format.html { redirect_to @student }
      else
        format.html { render :show }
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
      else
        format.html { render :show }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    @student.enrollments.each(&:destroy)

    @student.destroy
    respond_to do |format|
      flash[:success] = 'Student was successfully destroyed.'
      format.html { redirect_to students_url }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_student
    @student = Student.find(params[:id])
  end

  def admin_or_teacher?
    return if @current_user&.admin_or_teacher_of_student?(@student, @current_year)

    flash[:warning] = 'Action not allowed.'
    redirect_back(fallback_location: root_path)
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
