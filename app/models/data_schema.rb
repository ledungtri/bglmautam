# == Schema Information
#
# Table name: data_schemas
#
#  id         :integer          not null, primary key
#  deleted_at :datetime
#  entity     :string           not null
#  fields     :jsonb            not null
#  key        :string           not null
#  title      :string
#  weight     :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class DataSchema < ApplicationRecord
  has_many :data_fields

end
