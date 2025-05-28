class Api::ClassroomsController < ApplicationController
  skip_before_action :auth
  before_action :set_classroom, except: %i[index]

  def index
    @classrooms = scope.result.sort_by(&:sort_param)

    render json: @classrooms
  end

  def show
    render json: @classroom
  end

private

  def scope
    Classroom.ransack(params[:filters])
  end

  def set_classroom
    @classroom = Classroom.find(params[:id] || params[:classroom_id])
  end
end
