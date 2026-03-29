# == Schema Information
#
# Table name: attendances
#
#  id                    :integer          not null, primary key
#  attendable_type       :string
#  date                  :date             not null
#  deleted_at            :datetime
#  note                  :string
#  notice_date           :date
#  reason                :string
#  status                :string           not null
#  substitute_lesson     :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  attendable_id         :integer
#  substitute_teacher_id :integer
#
# Indexes
#
#  idx_on_attendable_type_attendable_id_date_7297b26825    (attendable_type,attendable_id,date)
#  index_attendances_on_attendable_type_and_attendable_id  (attendable_type,attendable_id)
#
class AttendanceSerializer < ApplicationSerializer
  attributes :date, :status, :reason, :substitute_teacher_id, :substitute_lesson, :note, :attendable_type, :attendable_id
  belongs_to :attendable
  belongs_to :substitute_teacher, record_type: :teacher, serializer: TeacherSerializer, optional: true
end
