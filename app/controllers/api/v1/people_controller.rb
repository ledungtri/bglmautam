# frozen_string_literal: true

module Api
  module V1
    class PeopleController < BaseController
      before_action :set_person, only: [:show, :update]

      # GET /api/v1/people
      def index
        @people = scope.result.page(params[:page]).per(params[:per_page] || 50)
        render json: {
          data: ActiveModelSerializers::SerializableResource.new(@people),
          meta: pagination_meta(@people)
        }
      end

      # GET /api/v1/people/:id
      def show
        render json: @person
      end

      # PATCH/PUT /api/v1/people/:id
      def update
        authorize @person

        if @person.update(person_params)
          render json: @person
        else
          render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def scope
        base = Person.all

        # Filter by role: student (has enrollments) or teacher (has teaching_assignments)
        case params[:role]
        when 'student'
          base = base.joins(:enrollments).distinct
          base = base.joins('INNER JOIN classrooms ON classrooms.id = enrollments.classroom_id')
                     .where(classrooms: { year: params[:year] }) if params[:year].present?
        when 'teacher'
          base = base.joins(:teaching_assignments).distinct
          base = base.joins('INNER JOIN classrooms ON classrooms.id = teaching_assignments.classroom_id')
                     .where(classrooms: { year: params[:year] }) if params[:year].present?
        end

        base.ransack(params[:filters])
      end

      def set_person
        @person = Person.find(params[:id])
      end

      def person_params
        params.require(:person).permit(
          :first_name, :middle_name, :last_name, :full_name,
          :christian_name, :date_of_birth, :sex, :avatar_url
        )
      end
    end
  end
end
