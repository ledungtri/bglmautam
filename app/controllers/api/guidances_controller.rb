class Api::GuidancesController < ApplicationController
  skip_before_action :auth # TODO: authorize

  def index
    @guidances = Guidance.joins(:classroom).where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
    render json: @guidances
  end

  def show
    @guidance = Guidance.find(params[:id])
    render json: @guidance
  end
end
