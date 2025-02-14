class Api::GuidancesController < ApplicationController
  skip_before_action :auth

  def index
    @guidances = Guidance.joins(:classroom).where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
    render json: @guidances
  end
end
