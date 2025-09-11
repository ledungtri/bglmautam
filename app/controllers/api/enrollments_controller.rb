class Api::EnrollmentsController < ApplicationController
  skip_before_action :auth # TODO: authorize

  def index
    @enrollments = scope.result.sort_by(&:sort_param)
    render json: @enrollments
  end

  def show
    @enrollment = Enrollment.find(params[:id])
    render json: @enrollment
  end

  def scope
    Enrollment.joins(:classroom).where('classrooms.year = ?', @current_year).ransack(params[:filters])
  end
end
