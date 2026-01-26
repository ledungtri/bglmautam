# frozen_string_literal: true

module Api
  module V1
    class AttendancesController < BaseController
      before_action :set_attendance, only: [:show, :update, :destroy]

      # GET /api/v1/attendances
      def index
        @attendances = scope.result.page(params[:page]).per(params[:per_page] || 100)

        # Filter by date range
        if params[:start_date].present? && params[:end_date].present?
          @attendances = @attendances.where(date: params[:start_date]..params[:end_date])
        end

        # Filter by classroom (through enrollments)
        if params[:classroom_id].present?
          enrollment_ids = Enrollment.where(classroom_id: params[:classroom_id]).pluck(:id)
          @attendances = @attendances.where(attendable_type: 'Enrollment', attendable_id: enrollment_ids)
        end

        render json: @attendances, meta: pagination_meta(@attendances)
      end

      # GET /api/v1/attendances/:id
      def show
        render json: @attendance
      end

      # POST /api/v1/attendances
      def create
        @attendance = Attendance.new(attendance_params)
        authorize_attendance

        if @attendance.save
          render json: @attendance, status: :created
        else
          render json: { errors: @attendance.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/attendances/:id
      def update
        authorize_attendance

        if @attendance.update(attendance_params)
          render json: @attendance
        else
          render json: { errors: @attendance.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/attendances/:id
      def destroy
        authorize_attendance
        @attendance.destroy
        head :no_content
      end

      private

      def scope
        Attendance.ransack(params[:filters])
      end

      def set_attendance
        @attendance = Attendance.find(params[:id])
      end

      def attendance_params
        params.require(:attendance).permit(:attendable_type, :attendable_id, :date, :status, :note)
      end

      def authorize_attendance
        # Check if user has permission for the related enrollment/classroom
        if @attendance.attendable_type == 'Enrollment'
          enrollment = @attendance.attendable || Enrollment.find(@attendance.attendable_id)
          authorize enrollment, :update?
        end
      end
    end
  end
end
