# frozen_string_literal: true

module Api
  module V1
    class EnrollmentsController < BaseController
      before_action :set_enrollment, only: [:show, :update, :destroy]

      # GET /api/v1/enrollments
      def index
        # `.includes(:grades, :attendances, ...)` here would combine two `has_many`
        # associations in one call — Rails responds by eager-loading everything through
        # a single JOIN, which fans out into a grades × attendances cartesian product
        # per enrollment. At a few hundred enrollments that's tens of thousands of
        # duplicate rows to deserialize in Ruby. The explicit preloader issues one
        # simple batched query per association instead (both `student` and `person` are
        # needed: `student` for `sort_param`, `person` for `EnrollmentSerializer`).
        @enrollments = scope.result.unscope(:includes, :order).to_a
        ActiveRecord::Associations::Preloader.new(
          records: @enrollments,
          associations: [:person, :classroom, :student, :grades, :attendances, :evaluation]
        ).call
        render_collection @enrollments.sort_by(&:sort_param)
      end

      # GET /api/v1/enrollments/:id
      def show
        render_resource @enrollment
      end

      # POST /api/v1/enrollments
      def create
        @enrollment = Enrollment.new(enrollment_params)
        authorize @enrollment

        if @enrollment.save
          render_resource @enrollment, status: :created
        else
          render json: { errors: @enrollment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/enrollments/:id
      def update
        authorize @enrollment

        if @enrollment.update(enrollment_params)
          render_resource @enrollment
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
        params.require(:enrollment).permit(:person_id, :classroom_id, :result)
      end
    end
  end
end
