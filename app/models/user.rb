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

  def admin_or_self?(user)
    admin? || self?(user)
  end

  def admin_or_teacher_of_classroom?(classroom, year)
    admin? || teacher_of_classroom?(classroom, year)
  end

  def admin_or_self_teacher?(teacher)
    admin? || self_teacher?(teacher)
  end

  def admin_or_self_guidance?(guidance)
    admin? || self_guidance?(guidance)
  end

  def admin_or_teacher_of_enrollment?(enrollment, year)
    admin? || teacher_of_enrollment?(enrollment, year)
  end

  def admin_or_teacher_of_student?(student, year)
    admin? || teacher_of_student?(student, year)
  end

  def self?(user)
    self == user
  end

  def self_teacher?(teacher)
    self?(teacher.user)
  end

  def self_guidance?(guidance)
    self_teacher?(guidance.teacher)
  end

  def teacher_of_classroom?(classroom, year)
    self.teacher&.guidances&.for_year(year)&.map(&:classroom)&.include?(classroom)
  end

  def teacher_of_enrollment?(enrollment, year)
    teacher_of_classroom?(enrollment&.classroom, year)
  end

  def teacher_of_student?(student, year)
    teacher_of_enrollment?(student.enrollments.for_year(year)&.first, year)
  end

private

  def sync_person
    self.person_id = teacher.person_id
  end
end
