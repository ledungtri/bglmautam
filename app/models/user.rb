# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  admin           :boolean
#  deleted_at      :datetime
#  password_digest :string
#  username        :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  teacher_id      :integer
#
# Indexes
#
#  index_users_on_deleted_at  (deleted_at)
#
class User < ApplicationRecord
  has_secure_password
  belongs_to :teacher

  def admin_or_self?(user)
    admin? || self?(user)
  end

  def admin_or_teacher_of_classroom?(classroom)
    admin? || teacher_of_classroom?(classroom)
  end

  def admin_or_self_teacher?(teacher)
    admin? || self_teacher?(teacher)
  end

  def admin_or_self_guidance?(guidance)
    admin? || self_guidance?(guidance)
  end

  def admin_or_teacher_of_enrollment?(enrollment)
    admin? || teacher_of_enrollment?(enrollment)
  end

  def admin_or_teacher_of_student?(student)
    admin? || teacher_of_student?(student)
  end

private

  def self?(user)
    self == user
  end

  def self_teacher?(teacher)
    self?(teacher.user)
  end

  def self_guidance?(guidance)
    self_teacher?(guidance.teacher)
  end

  def teacher_of_classroom?(classroom)
    classroom == self.teacher&.guidances&.for_year(2021)&.first&.classroom
  end

  def teacher_of_enrollment?(enrollment)
    teacher_of_classroom?(enrollment&.classroom)
  end

  def teacher_of_student?(student)
    teacher_of_enrollment?(student.enrollments.for_year(@current_year)&.first)
  end
end
