class Api::ClassroomsController < ApplicationController
  skip_before_action :auth # TODO: authorize
  before_action :set_classroom, except: %i[index create]

  def index
    # authorize Classroom
    @classrooms = scope.result.sort_by(&:sort_param)
    render json: @classrooms
  end

  def show
    render json: @classroom
  end

  def students
    render json: @classroom.enrollments
  end

  def teachers
    render json: @classroom.teaching_assignments
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
