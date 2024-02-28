class SecondaryResourcesController < ApplicationController
  before_action :auth
  before_action :set_record, only: [:update, :destroy]

  # POST /records
  def create
    @record = model_klass.new(record_params)
    flash[:success] = "#{model_klass.to_s} was successfully created." if @record.save
    redirect_back(fallback_location: root_path)
  end

  # PATCH/PUT /records/1
  def update
    flash[:success] = "#{model_klass.to_s} was successfully updated." if @record.update(record_params)
    redirect_back(fallback_location: root_path)
  end

  # DELETE /records/1
  def destroy
    @record.destroy
    flash[:success] = "#{model_klass.to_s} was successfully destroyed."
    redirect_back(fallback_location: root_path)
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
end
