# frozen_string_literal: true

module Api
  module V1
    class DataSchemasController < BaseController
      before_action :require_admin!
      before_action :set_data_schema, only: [:show, :update, :destroy]

      # GET /api/v1/data_schemas
      def index
        @data_schemas = scope.result.order(:entity, :weight).page(params[:page]).per(params[:per_page] || 50)
        render_collection @data_schemas, meta: pagination_meta(@data_schemas)
      end

      # GET /api/v1/data_schemas/:id
      def show
        render_resource @data_schema
      end

      # POST /api/v1/data_schemas
      def create
        @data_schema = DataSchema.new(data_schema_params)

        if @data_schema.save
          render_resource @data_schema, status: :created
        else
          render json: { errors: @data_schema.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/data_schemas/:id
      def update
        if @data_schema.update(data_schema_params)
          render_resource @data_schema
        else
          render json: { errors: @data_schema.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/data_schemas/:id
      def destroy
        @data_schema.destroy
        head :no_content
      end

      # GET /api/v1/data_schemas/options
      def options
        render json: {
          entities: DataSchema::SUPPORTED_ENTITIES,
          field_types: DataSchema::SUPPORTED_FIELD_TYPES
        }
      end

      private

      def require_admin!
        render json: { error: 'Admin access required' }, status: :forbidden unless current_user.admin?
      end

      def scope
        DataSchema.ransack(params[:filters])
      end

      def set_data_schema
        @data_schema = DataSchema.find(params[:id])
      end

      def data_schema_params
        params.require(:data_schema).permit(:key, :entity, :title, :weight, fields: [:field, :label, :field_type, :required, options: []])
      end
    end
  end
end
