# frozen_string_literal: true

module Api
  module V1
    class PeopleController < BaseController
      before_action :set_person, only: [:show, :update, :destroy]

      # GET /api/v1/people
      def index
        @people = scope.result.page(params[:page]).per(params[:per_page] || 50)
        render_collection @people, meta: pagination_meta(@people)
      end

      # GET /api/v1/people/:id
      def show
        render_resource @person
      end

      # PATCH/PUT /api/v1/people/:id
      def update
        authorize @person

        if @person.update(person_params)
          render_resource @person
        else
          render json: { errors: @person.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/people/:id
      def destroy
        authorize @person

        @person.enrollments.each(&:destroy)
        @person.teaching_assignments.each(&:destroy)
        @person.student&.destroy
        @person.teacher&.destroy
        @person.user&.destroy

        @person.destroy
        head :no_content
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
          :christian_name, :name, :nickname, :birth_date, :birth_place, :gender, :avatar_url,
          :phone, :email,
          :street_number, :street_name, :ward, :district, :city, :area
        )
      end
    end
  end
end
