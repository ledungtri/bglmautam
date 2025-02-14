class Api::SecondaryResourcesController < ActionController::Base
  # skip_before_action :auth
  before_action :set_record, only: [:update, :destroy]

  # POST /records
  def create
    @record = model_klass.new(record_params)
    render json: @record if @record.save
  end

  # PATCH/PUT /records/1
  def update
    render json: @record if @record.update(record_params)
  end

  # DELETE /records/1
  def destroy
    render json: @record if @record.destroy
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_record
    @record = model_klass.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def record_params
    params.require(model_klass.to_s.parameterize).permit(permit_params)
  end

  def model_klass
    raise NotImplementedError, "You must implement model_klass method for #{self.class}."
  end

  def permit_params
    raise NotImplementedError, "You must implement permit_params method for #{self.class}."
  end
end
