# frozen_string_literal: true

module Api
  module V1
    class ResourceTypesController < BaseController
      # GET /api/v1/resource_types/:key
      def index
        @resource_types = ResourceType.for_key(params[:key])
        render_collection @resource_types
      end
    end
  end
end
