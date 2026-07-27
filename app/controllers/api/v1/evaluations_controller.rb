# frozen_string_literal: true

module Api
  module V1
    class EvaluationsController < BaseController
      before_action :set_evaluation, only: [:update, :destroy]

      # POST /api/v1/evaluations
      def create
        @evaluation = Evaluation.new(evaluation_params)
        authorize_evaluation

        if @evaluation.save
          render_resource @evaluation, status: :created
        else
          render json: { errors: @evaluation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/evaluations/:id
      def update
        authorize_evaluation

        if @evaluation.update(evaluation_params)
          render_resource @evaluation
        else
          render json: { errors: @evaluation.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/evaluations/:id
      def destroy
        authorize_evaluation
        @evaluation.destroy
        head :no_content
      end

      private

      def set_evaluation
        @evaluation = Evaluation.find(params[:id])
      end

      def evaluation_params
        params.require(:evaluation).permit(:content, :evaluable_type, :evaluable_id)
      end

      def authorize_evaluation
        case @evaluation.evaluable_type
        when 'Enrollment'
          enrollment = @evaluation.evaluable || Enrollment.find(@evaluation.evaluable_id)
          authorize enrollment, :update?
        when 'TeachingAssignment'
          teaching_assignment = @evaluation.evaluable || TeachingAssignment.find(@evaluation.evaluable_id)
          authorize teaching_assignment, :update?
        else
          raise Pundit::NotAuthorizedError
        end
      end
    end
  end
end
