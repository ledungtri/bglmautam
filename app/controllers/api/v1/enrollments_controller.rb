# frozen_string_literal: true

module Api
  module V1
    class EnrollmentsController < BaseController
      before_action :set_enrollment, only: [:show, :update, :destroy]

      # GET /api/v1/enrollments
      def index
        @enrollments = scope.result.page(params[:page]).per(params[:per_page] || 50)
        render json: @enrollments, meta: pagination_meta(@enrollments)
      end

      # GET /api/v1/enrollments/:id
      def show
        render json: @enrollment
      end

      # POST /api/v1/enrollments
      def create
        @enrollment = Enrollment.new(enrollment_params)
        authorize @enrollment

        if @enrollment.save
          render json: @enrollment, status: :created
        else
          render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/enrollments/:id
      def update
        authorize @enrollment

        if @enrollment.update(enrollment_params)
          render json: @enrollment
        else
          render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/enrollments/:id
      def destroy
        authorize @enrollment
        @enrollment.destroy
        head :no_content
      end

      private

      def scope
        Enrollment.ransack(params[:filters])
      end

      def set_enrollment
        @enrollment = Enrollment.find(params[:id])
      end

      def enrollment_params
        params.require(:enrollment).permit(:student_id, :classroom_id, :result)
      end
    end
  end
end
