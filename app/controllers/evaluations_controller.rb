class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: %i[ update destroy admin_or_teacher_of? ]
  before_action :auth
  before_action :admin_or_teacher_of?, only: %i[update destroy]

  # POST /evaluations or /evaluations.json
  def create
    @evaluation = Evaluation.new(evaluation_params)

    respond_to do |format|
      if @evaluation.save
        flash[:success] = 'Evaluation was successfully created.'
      else
        flash[:error] = 'Evaluation was not successfully created.'
      end
      format.html { redirect_to edit_enrollment_url(@evaluation.evaluable) }
    end
  end

  # PATCH/PUT /evaluations/1 or /evaluations/1.json
  def update
    respond_to do |format|
      if @evaluation.update(evaluation_params)
        flash[:success] = 'Evaluation was successfully updated.'
      else
        flash[:error] = 'Evaluation was not successfully updated.'
      end
      format.html { redirect_to edit_enrollment_url(@evaluation.evaluable) }
    end
  end

  # DELETE /evaluations/1 or /evaluations/1.json
  def destroy
    @evaluation.destroy

    respond_to do |format|
      format.html { redirect_to evaluations_url, notice: "Evaluation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

private

  def admin_or_teacher_of?
    return if @current_user&.admin_or_teacher_of_enrollment?(@evaluation.evaluable, @current_year)

    flash[:warning] = 'Action not allowed.'
    redirect_to :back || root_path
  end

  def evaluations_scope
    parent = if params[:classroom_id].present?
               Classroom.find(params[:classroom_id]).evaluations
             elsif params[:enrollment_id].present?
               Enrollment.find(params[:enrollment_id]).evaluations
             end

    parent ? parent.evaluations : Evaluation.all
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_evaluation
    @evaluation = Evaluation.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def evaluation_params
    params.require(:evaluation).permit(:content, :evaluable_type, :evaluable_id)
  end
end
