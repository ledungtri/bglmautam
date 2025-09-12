# == Schema Information
#
# Table name: classrooms
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  family     :string
#  group      :string
#  level      :integer
#  location   :string
#  year       :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_classrooms_on_deleted_at  (deleted_at)
#
class ClassroomSerializer < ApplicationSerializer
  attributes :year, :long_year, :name, :family, :group, :level, :location, :enrollments_overview
end
