# == Schema Information
#
# Table name: attendances
#
#  id              :integer          not null, primary key
#  attendable_type :string
#  date            :date             not null
#  deleted_at      :datetime
#  note            :string
#  notice_date     :date
#  status          :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attendable_id   :integer
#
# Indexes
#
#  index_attendances_on_attendable_type_and_attendable_id  (attendable_type,attendable_id)
#
class AttendancesController < SecondaryResourcesController

private

  def model_klass
    Attendance
  end

  def permit_params
    [:status, :date, :notice_date, :note, :attendable_type, :attendable_id]
  end
end
