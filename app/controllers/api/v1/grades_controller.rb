# frozen_string_literal: true

module Api
  module V1
    class GradesController < BaseController
      before_action :set_grade, only: [:update, :destroy]

      # POST /api/v1/grades
      def create
        @grade = Grade.new(grade_params)
        authorize_grade

        if @grade.save
          render_resource @grade, status: :created
        else
          render json: { errors: @grade.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/grades/:id
      def update
        authorize_grade

        if @grade.update(grade_params)
          render_resource @grade
        else
          render json: { errors: @grade.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/grades/:id
      def destroy
        authorize_grade
        @grade.destroy
        head :no_content
      end

      private

      def set_grade
        @grade = Grade.find(params[:id])
      end

      def grade_params
        params.require(:grade).permit(:name, :value, :weight, :enrollment_id)
      end

      def authorize_grade
        enrollment = @grade.enrollment || Enrollment.find(@grade.enrollment_id)
        authorize enrollment, :update?
      end
    end
  end
end
