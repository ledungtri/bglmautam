class Api::ResourceTypesController < ApplicationController
  skip_before_action :auth # TODO: authorize

  def index
    @resource_types = ResourceType.for_key(params[:key])
    render json: @resource_types
  end
end
