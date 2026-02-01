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
#  idx_on_attendable_type_attendable_id_date_7297b26825    (attendable_type,attendable_id,date)
#  index_attendances_on_attendable_type_and_attendable_id  (attendable_type,attendable_id)
#
class Attendance < ApplicationRecord
  belongs_to :attendable, polymorphic: true

  validates_presence_of :date, :status, :attendable_type, :attendable_id

  def self.ransackable_attributes(auth_object = nil)
    %w[date status attendable_type attendable_id note notice_date]
  end

  before_save :reconcile_status

private

  def reconcile_status
    return if status || !notice_date
    self.status = 'Báo Trễ' if notice_date > date - 3.days
    self.status = 'Có Phép'
  end
end
