class Api::DataSchemasController < ApplicationController
  skip_before_action :auth # TODO: authorize
  before_action :set_data_schema, only: %i[ show update destroy ]

  def index
    # authorize DataSchema
    @data_schemas = scope.result
    render json: @data_schemas
  end

  def show
    # authorize @data_schema
    render json: @data_schema
  end

  def create
    # authorize DataSchema
    @data_schema = scope.new(data_schema_params)

    if @data_schema.save
      render json: @data_schema, status: :created, location: @data_schema
    else
      render json: @data_schema.errors, status: :unprocessable_entity
    end
  end

  def update
    # authorize @data_schema
    if @data_schema.update(data_schema_params)
      render json: @data_schema
    else
      render json: @data_schema.errors, status: :unprocessable_entity
    end
  end

  def destroy
    # authorize @data_schema
    @data_schema.destroy!
  end

private

  def set_data_schema
    @data_schema = DataSchema.find(params[:id])
  end

  def scope
    DataSchema.ransack(params[:filters])
  end

  def data_schema_params
    params.require(:data_schema).permit(
      :entity,
      :title,
      :key,
      :weight,
      fields: [
        :label,
        :field_name,
        :field_type
      ]
    )
  end
end
