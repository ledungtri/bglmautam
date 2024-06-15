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
class Attendance < ApplicationRecord
  belongs_to :attendable, polymorphic: true

  validates_presence_of :date, :status, :attendable_type, :attendable_id

  before_save :reconcile_status

  STATUS_OPTIONS = ['Hiện Diện', 'Có Phép', 'Báo Trễ', 'Không Phép']

private

  def reconcile_status
    return if status || !notice_date
    self.status = 'Báo Trễ' if notice_date > date - 3.days
    self.status = 'Có Phép'
  end
end
