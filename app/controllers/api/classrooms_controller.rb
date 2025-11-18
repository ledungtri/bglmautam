class Api::ClassroomsController < ApplicationController
  skip_before_action :auth # TODO: authorize
  before_action :set_classroom, except: %i[index create]

  def index
    # authorize Classroom
    @classrooms = scope.result.where(family: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời']).sort_by(&:sort_param)

    respond_to do |format|
      format.json { render json: @classrooms }
      format.pdf do
        send_data ClassroomsPdf.new(@classrooms).render,
                  filename: "Thống Kê Các Lớp Năm Học #{@classrooms.first.long_year}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end
    end
  end

  def show
    render json: @classroom
  end

  def students
    render json: @classroom.enrollments
  end

  def teachers
    render json: @classroom.guidances
  end

  def create

  end

private

  def scope
    Classroom.ransack(params[:filters])
  end

  def set_classroom
    @classroom = Classroom.find(params[:id] || params[:classroom_id])
  end

  def classroom_params
    params.require(:classroom).permit(
      :year,
      :family,
      :level,
      :group,
      :location
    )
  end
end
