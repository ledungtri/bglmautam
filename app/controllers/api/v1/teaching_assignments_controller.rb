# frozen_string_literal: true

module Api
  module V1
    class TeachingAssignmentsController < BaseController
      before_action :set_teaching_assignment, only: [:show, :update, :destroy]

      # GET /api/v1/teaching_assignments
      def index
        @teaching_assignments = scope.result.page(params[:page]).per(params[:per_page] || 50)
        render json: @teaching_assignments, meta: pagination_meta(@teaching_assignments)
      end

      # GET /api/v1/teaching_assignments/:id
      def show
        render json: @teaching_assignment
      end

      # POST /api/v1/teaching_assignments
      def create
        @teaching_assignment = TeachingAssignment.new(teaching_assignment_params)
        authorize @teaching_assignment

        if @teaching_assignment.save
          render json: @teaching_assignment, status: :created
        else
          render json: { errors: @teaching_assignment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/teaching_assignments/:id
      def update
        authorize @teaching_assignment

        if @teaching_assignment.update(teaching_assignment_params)
          render json: @teaching_assignment
        else
          render json: { errors: @teaching_assignment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/teaching_assignments/:id
      def destroy
        authorize @teaching_assignment
        @teaching_assignment.destroy
        head :no_content
      end

      private

      def scope
        TeachingAssignment.ransack(params[:filters])
      end

      def set_teaching_assignment
        @teaching_assignment = TeachingAssignment.find(params[:id])
      end

      def teaching_assignment_params
        params.require(:teaching_assignment).permit(:teacher_id, :classroom_id, :position)
      end
    end
  end
end
