# == Schema Information
#
# Table name: grades
#
#  id            :integer          not null, primary key
#  deleted_at    :datetime
#  value         :float
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  enrollment_id :integer
#
# Indexes
#
#  index_grades_on_enrollment_id  (enrollment_id)
#
class Grade < ApplicationRecord
  belongs_to :enrollment
end
