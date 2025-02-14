class Api::ClassroomsController < ApplicationController
  skip_before_action :auth

  def index
    @classrooms = Classroom.where(year: @current_year).where(family: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời']).sort_by(&:sort_param)

    render json: @classrooms
  end
end
