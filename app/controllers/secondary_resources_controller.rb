class SecondaryResourcesController < ApplicationController
  before_action :auth
  before_action :set_record, only: [:update, :destroy]

  # POST /records
  def create
    @record = model_klass.new(record_params)
    saved = @record.save
    return if @skip_redirect && saved

    flash[:success] = "#{model_klass.to_s} was successfully created." if saved
    redirect_back(fallback_location: root_path)
  end

  # PATCH/PUT /records/1
  def update
    updated = @record.update(record_params)
    return if @skip_redirect && updated

    flash[:success] = "#{model_klass.to_s} was successfully updated." if updated
    redirect_back(fallback_location: root_path)
  end

  # DELETE /records/1
  def destroy
    @record.destroy
    return if @skip_redirect

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

  def model_klass
    raise NotImplementedError, "You must implement model_klass method for #{self.class}."
  end

  def permit_params
    raise NotImplementedError, "You must implement permit_params method for #{self.class}."
  end

  def skip_redirect
    @skip_redirect = true
  end

end
