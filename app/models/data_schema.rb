# == Schema Information
#
# Table name: data_schemas
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  entity     :string
#  fields     :jsonb
#  key        :string
#  title      :string
#  weight     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class DataSchema < ApplicationRecord
  has_many :data_fields

end
