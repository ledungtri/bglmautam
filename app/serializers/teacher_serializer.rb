# == Schema Information
#
# Table name: teachers
#
#  id             :bigint           not null, primary key
#  christian_name :string
#  date_birth     :date
#  deleted_at     :datetime
#  district       :string
#  email          :string
#  full_name      :string
#  gender         :string
#  named_date     :string
#  nickname       :string
#  occupation     :string
#  phone          :string
#  street_name    :string
#  street_number  :string
#  ward           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  person_id      :integer
#
# Indexes
#
#  index_teachers_on_deleted_at  (deleted_at)
#
class TeacherSerializer < ApplicationSerializer
  attributes :christian_name, :full_name, :name, :date_birth, :phone, :person_id
end
