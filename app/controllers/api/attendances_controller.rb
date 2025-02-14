class Api::AttendancesController < Api::SecondaryResourcesController
  def index
    scope = Attendance.order(date: :desc).where(attendable_type: :Guidance)
    scope = scope.where(attendable_id: params[:guidance_id]) if params[:guidance_id]
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
