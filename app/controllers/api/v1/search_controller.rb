# frozen_string_literal: true

module Api
  module V1
    class SearchController < BaseController
      # GET /api/v1/search
      def index
        query = params[:query]
        year = params[:year]&.to_i || Time.current.year

        results = { students: [], teachers: [] }

        if query.present?
          # Search people with enrollments (students)
          students = Person.joins(:enrollments)
                          .where('name ILIKE ?', "%#{query}%")
                          .distinct
                          .limit(20)
          results[:students] = students.map do |person|
            enrollment = person.enrollments.joins(:classroom).where(classrooms: { year: year }).first
            enrollment ||= person.enrollments.order(created_at: :desc).first
            {
              id: person.id,
              name: person.name,
              christian_name: person.christian_name,
              enrollment: enrollment ? {
                id: enrollment.id,
                result: enrollment.result,
                classroom: enrollment.classroom ? {
                  id: enrollment.classroom.id,
                  name: enrollment.classroom.name,
                  year: enrollment.classroom.year
                } : nil
              } : nil
            }
          end

          # Search people with teaching assignments (teachers)
          teachers = Person.joins(:teaching_assignments)
                          .where('name ILIKE ?', "%#{query}%")
                          .distinct
                          .limit(20)
          results[:teachers] = teachers.map do |person|
            teaching_assignment = person.teaching_assignments.joins(:classroom).where(classrooms: { year: year }).first
            teaching_assignment ||= person.teaching_assignments.order(created_at: :desc).first
            {
              id: person.id,
              name: person.name,
              christian_name: person.christian_name,
              teaching_assignment: teaching_assignment ? {
                id: teaching_assignment.id,
                position: teaching_assignment.position,
                classroom: teaching_assignment.classroom ? {
                  id: teaching_assignment.classroom.id,
                  name: teaching_assignment.classroom.name,
                  year: teaching_assignment.classroom.year
                } : nil
              } : nil
            }
          end
        end

        render_resource results
      end
    end
  end
end
