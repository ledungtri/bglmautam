# frozen_string_literal: true

module Api
  module V1
    class ClassroomsController < BaseController
      before_action :set_classroom, except: [:index, :create, :overview, :custom_export, :statistics_pdf]

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

      # GET /api/v1/classrooms/:id/enrollments
      def enrollments
        render_collection @classroom.enrollments.sort_by(&:sort_param)
      end

      # GET /api/v1/classrooms/:id/teaching_assignments
      def teaching_assignments
        render_collection @classroom.teaching_assignments.sort_by(&:sort_param)
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
        enrollments = @classroom.enrollments.includes(:person, :evaluation, :grades, :attendances).sort_by(&:sort_param)
        data = enrollments.map do |enrollment|
          attendances = enrollment.attendances
          attended_count = attendances.count { |a| a.status == 'Hiện Diện' }
          mass_absence_count = attendances.count { |a| a.status == 'Vắng Lễ' }
          absence_count = attendances.count - attended_count - mass_absence_count
          {
            id: enrollment.id,
            result: enrollment.result,
            person: serialize(enrollment.person),
            classroom: { id: @classroom.id },
            evaluation: enrollment.evaluation ? serialize(enrollment.evaluation) : nil,
            grades: serialize(enrollment.grades),
            average_grade: enrollment.average_grade,
            attended_count: attended_count,
            mass_absence_count: mass_absence_count,
            absence_count: absence_count
          }
        end
        render json: { data: data }
      end

      # GET /api/v1/classrooms/:id/students_pdf
      def students_pdf
        enrollments = @classroom.enrollments.sort_by(&:sort_param)
        pdf = StudentsPdf.new(enrollments, "Danh Sách Lớp #{@classroom.name}\nNăm Học #{@classroom.long_year}")
        send_data pdf.render,
                  filename: "Danh Sách Lớp #{@classroom.name} Năm Học #{@classroom.long_year}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end

      # GET /api/v1/classrooms/:id/personal_details_pdf
      def personal_details_pdf
        students = Student.in_classroom(@classroom).sort_by(&:sort_param)
        pdf = StudentsPersonalDetailsPdf.new(students)
        send_data pdf.render,
                  filename: "Sơ Yếu Lý Lịch Lớp #{@classroom.name} Năm Học #{@classroom.long_year}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end

      # GET /api/v1/classrooms/:id/students_xlsx
      def students_xlsx
        xlsx = StudentsExcelExport.new(@classroom).generate
        send_data xlsx,
                  filename: "#{@classroom.name} Năm Học #{@classroom.long_year}.xlsx",
                  type: 'application/xlsx',
                  disposition: 'attachment'
      end

      # GET /api/v1/classrooms/:id/classroom_custom_export
      def classroom_custom_export
        pdf = CustomStudentsPdf.new(
          @classroom,
          "#{@classroom.name} - #{params[:title]}\nNăm Học #{@classroom.long_year}",
          params[:page_layout].to_sym,
          params[:columns].split(','),
          params[:current_students_only]
        )
        send_data pdf.render,
                  filename: "#{@classroom.name} - #{params[:title]}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end

      # GET /api/v1/classrooms/custom_export
      def custom_export
        year = params[:year] || Date.current.year
        classrooms = Classroom.where(year: year)
                              .where(family: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời'])
                              .sort_by(&:sort_param)

        if classrooms.empty?
          return render json: { error: 'No classrooms found' }, status: :not_found
        end

        pdf = ClassroomsCustomPdf.new(classrooms, params[:title], params[:page_layout].to_sym, params[:columns].split(','))
        send_data pdf.render,
                  filename: "#{params[:title]}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
      end

      # GET /api/v1/classrooms/overview?year=2025
      def overview
        authorize Classroom
        year = params[:year] || 2025
        classrooms = Classroom.where(year: year).sort_by(&:sort_param)
        result_types = ResourceType.for_key('enrollment_result').pluck(:value)

        data = classrooms.map do |classroom|
          enrollments = classroom.enrollments.includes(:grades, :attendances, :evaluation)
          teaching_assignments = serialize(classroom.teaching_assignments.includes(:person).sort_by(&:sort_param))

          year_start = Date.new(year.to_i, 9, 1).then { |d| d + ((7 - d.wday) % 7) }
          year_end   = Date.new(year.to_i + 1, 5, 31)
          sundays    = (year_start..year_end).select(&:sunday?)

          active_enrollment_count = enrollments.count { |e| ['Đang Học', 'Lên Lớp'].include?(e.result) }

          grade_status = lambda do |count|
            return nil if active_enrollment_count == 0
            coverage = count.to_f / active_enrollment_count
            if coverage >= 0.9 then 'good'
            elsif coverage >= 0.7 then 'medium'
            else 'bad'
            end
          end

          grade_types = ['Giữa HK 1', 'Cuối HK 1', 'Giữa HK 2', 'Cuối HK 2']
          raw_grade_counts = enrollments.flat_map(&:grades).group_by(&:name).transform_values(&:count)
          grade_counts = grade_types.each_with_object({}) do |t, h|
            count = raw_grade_counts[t] || 0
            h[t] = { count: count, status: grade_status.call(count) }
          end
          evaluation_raw = enrollments.count { |e| e.evaluation.present? }
          evaluation_count = { count: evaluation_raw, status: grade_status.call(evaluation_raw) }
          attendance_dates = enrollments.flat_map(&:attendances).map(&:date)
          attendance_by_week = sundays.each_with_object({}) do |sunday, h|
            count = attendance_dates.count { |d| d == sunday }
            status = if sunday > Date.today || active_enrollment_count == 0
              nil
            else
              coverage = count.to_f / active_enrollment_count
              if coverage >= 0.9 then 'good'
              elsif coverage >= 0.7 then 'medium'
              else 'bad'
              end
            end
            h[sunday.to_s] = { count: count, status: status }
          end

          enrollments_by_result = enrollments.group_by(&:result)
          result_counts = result_types.each_with_object({}) do |type, h|
            h[type] = enrollments_by_result[type]&.count || 0
          end

          {
            id: classroom.id,
            name: classroom.name,
            year: classroom.year,
            family: classroom.family,
            location: classroom.location,
            teaching_assignments: teaching_assignments,
            enrollment_result_counts: result_counts,
            grade_counts: grade_counts,
            evaluation_count: evaluation_count,
            attendance_counts_by_week: attendance_by_week
          }
        end

        render json: { data: data }
      end

      # GET /api/v1/classrooms/statistics_pdf
      def statistics_pdf
        year = params[:year] || Date.current.year
        classrooms = Classroom.where(year: year)
                              .where(family: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời'])
                              .sort_by(&:sort_param)

        if classrooms.empty?
          return render json: { error: 'No classrooms found' }, status: :not_found
        end

        pdf = ClassroomsPdf.new(classrooms)
        send_data pdf.render,
                  filename: "Thống Kê Các Lớp Năm Học #{classrooms.first.long_year}.pdf",
                  type: 'application/pdf',
                  disposition: 'inline'
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
