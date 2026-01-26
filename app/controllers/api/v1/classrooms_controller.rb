# frozen_string_literal: true

module Api
  module V1
    class ClassroomsController < BaseController
      before_action :set_classroom, except: [:index, :create]

      # GET /api/v1/classrooms
      def index
        @classrooms = scope.result.page(params[:page]).per(params[:per_page] || 50)
        render_collection @classrooms.sort_by(&:sort_param), meta: pagination_meta(@classrooms)
      end

      # GET /api/v1/classrooms/:id
      def show
        render_resource @classroom
      end

      # POST /api/v1/classrooms
      def create
        authorize Classroom
        @classroom = Classroom.new(classroom_params)

        if @classroom.save
          render_resource @classroom, status: :created
        else
          render json: { errors: @classroom.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/classrooms/:id
      def update
        authorize @classroom

        if @classroom.update(classroom_params)
          render_resource @classroom
        else
          render json: { errors: @classroom.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/classrooms/:id
      def destroy
        authorize @classroom
        @classroom.destroy
        head :no_content
      end

      # GET /api/v1/classrooms/:id/students
      def students
        render_collection @classroom.enrollments
      end

      # GET /api/v1/classrooms/:id/teachers
      def teachers
        render_collection @classroom.teaching_assignments
      end

      # GET /api/v1/classrooms/:id/attendances
      def attendances
        attendances = Attendance.where(
          attendable_type: 'Enrollment',
          attendable_id: @classroom.enrollments.pluck(:id)
        )

        if params[:month].present? && params[:year].present?
          start_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
          end_date = start_date.end_of_month
          attendances = attendances.where(date: start_date..end_date)
        end

        render_collection attendances
      end

      # GET /api/v1/classrooms/:id/evaluations
      def evaluations
        render_collection @classroom.evaluations
      end

      private

      def scope
        Classroom.ransack(params[:filters])
      end

      def set_classroom
        @classroom = Classroom.find(params[:id] || params[:classroom_id])
      end

      def classroom_params
        params.require(:classroom).permit(:year, :family, :level, :group, :location)
      end
    end
  end
end
