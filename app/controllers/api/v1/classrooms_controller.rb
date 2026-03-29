# frozen_string_literal: true

module Api
  module V1
    class ClassroomsController < BaseController
      before_action :set_classroom, except: [:index, :create, :custom_export, :statistics_pdf]

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
