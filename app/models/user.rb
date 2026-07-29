# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  admin           :boolean          default(FALSE), not null
#  deleted_at      :datetime
#  password_digest :string           not null
#  username        :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  organization_id :bigint           not null
#  person_id       :integer
#  teacher_id      :integer
#
# Indexes
#
#  index_users_on_deleted_at       (deleted_at)
#  index_users_on_organization_id  (organization_id)
#  index_users_on_person_id        (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#  fk_rails_...  (person_id => people.id)
#
class User < ApplicationRecord
  acts_as_tenant :organization
  has_secure_password
  belongs_to :teacher, optional: true
  belongs_to :person

  validates_presence_of :username, :password_digest

  before_validation :sync_person

  FIELD_SETS = [
    {
      key: 'user',
      fields: [
        { field_name: :username, label: 'Tên Đăng Nhập' },
        { field_name: :teacher_id, field_type: :hidden_field },
        { field_name: :password, label: 'Mật Khẩu', field_type: :password_field },
        { field_name: :password_confirmation, label: 'Nhập Lại Mật Khẩu', field_type: :password_field }
      ]
    }
  ]

private

  def sync_person
    if person_id.blank? && teacher_id.present?
      self.person_id = Teacher.with_deleted.find(teacher_id).person_id
    elsif teacher_id.blank? && person_id.present?
      self.teacher_id = person&.teacher&.id
    end
  end
end
