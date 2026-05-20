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
#  person_id       :integer
#  teacher_id      :integer
#
# Indexes
#
#  index_users_on_deleted_at  (deleted_at)
#  index_users_on_person_id   (person_id)
#
# Foreign Keys
#
#  fk_rails_...  (person_id => people.id)
#
class User < ApplicationRecord
  has_secure_password
  belongs_to :teacher
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
    self.person_id = teacher.person_id
  end
end
