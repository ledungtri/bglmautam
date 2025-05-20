# == Schema Information
#
# Table name: grades
#
#  id            :integer          not null, primary key
#  deleted_at    :datetime
#  name          :string
#  value         :float
#  weight        :integer          default(1)
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

  def value
    super || 0
  end

  def weight
    super || 1
  end
end
