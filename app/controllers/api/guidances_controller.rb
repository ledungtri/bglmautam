class Api::GuidancesController < ApplicationController
  skip_before_action :auth # TODO: authorize

  def index
    @guidances = scope.result.sort_by(&:sort_param)
    render json: @guidances
  end

  def show
    @guidance = Guidance.find(params[:id])
    render json: @guidance
  end

  def scope
    Guidance.joins(:classroom).where('classrooms.year = ?', @current_year).ransack(params[:filters])
  end
end
