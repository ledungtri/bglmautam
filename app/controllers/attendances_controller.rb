class AttendancesController < SecondaryResourcesController

private

  def model_klass
    Attendance
  end

  def permit_params
    [:status, :date, :notice_date, :note, :attendable_type, :attendable_id]
  end
end
