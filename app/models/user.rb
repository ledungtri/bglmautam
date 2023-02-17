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
end
