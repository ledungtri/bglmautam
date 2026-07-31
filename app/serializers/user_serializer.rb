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
class UserSerializer < ApplicationSerializer
  attributes :username, :admin, :teacher_id, :person_id, :person_name, :person_christian_name, :person_birth_date, :person_phone

  def person_name
    object.person&.name
  end

  def person_christian_name
    object.person&.christian_name
  end

  def person_birth_date
    object.person&.birth_date
  end

  def person_phone
    object.person&.phone
  end
end
