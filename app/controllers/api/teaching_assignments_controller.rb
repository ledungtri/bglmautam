class Api::TeachingAssignmentsController < ApplicationController
  skip_before_action :auth # TODO: authorize

  def index
    @teaching_assignments = scope.result.sort_by(&:sort_param)
    render json: @teaching_assignments
  end

  def show
    @teaching_assignment = TeachingAssignment.find(params[:id])
    render json: @teaching_assignment
  end

  def scope
    TeachingAssignment.joins(:classroom).where('classrooms.year = ?', @current_year).ransack(params[:filters])
  end
end
