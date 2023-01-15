class GuidancesController < ApplicationController
  before_action :set_guidance, only: %i[show edit update destroy]
  before_action :auth, :admin?

  # GET /guidances/1
  # GET /guidances/1.json
  def show
  end

  # GET /guidances/1/edit
  def edit
  end

  # POST /guidances
  # POST /guidances.json
  def create
    @guidance = Guidance.new(guidance_params)

    respond_to do |format|
      if @guidance.save
        flash[:success] = 'Guidance was successfully created.'
        format.html { redirect_to "/teachers/#{@guidance.teacher_id}" }
      end
    end
  end

  # PATCH/PUT /guidances/1
  # PATCH/PUT /guidances/1.json
  def update
    respond_to do |format|
      if @guidance.update(guidance_params)
        flash[:success] = 'Guidance was successfully updated.'
        format.html { redirect_to "/teachers/#{@guidance.teacher_id}" }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /guidances/1
  # DELETE /guidances/1.json
  def destroy
    @guidance.destroy
    respond_to do |format|
      flash[:success] = 'Guidance was successfully destroyed.'
      format.html { redirect_to "/teachers/#{@guidance.teacher_id}" }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_guidance
    @guidance = Guidance.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def guidance_params
    params.require(:guidance).permit(:position, :teacher_id, :classroom_id)
  end
end
