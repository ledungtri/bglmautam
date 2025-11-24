class Api::AttendancesController < Api::SecondaryResourcesController
  def index
    scope = Attendance.order(date: :desc).where(attendable_type: :TeachingAssignment)
    scope = scope.where(attendable_id: params[:teaching_assignment_id]) if params[:teaching_assignment_id]
    render json: scope
  end

private

  def model_klass
    Attendance
  end

  def permit_params
    [:status, :date, :notice_date, :note, :attendable_type, :attendable_id]
  end
end
