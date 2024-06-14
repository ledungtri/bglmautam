# == Schema Information
#
# Table name: data_fields
#
#  id                  :integer          not null, primary key
#  data                :jsonb            not null
#  data_fieldable_type :string
#  deleted_at          :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  data_fieldable_id   :integer
#  data_schema_id      :integer
#
# Indexes
#
#  index_data_fields_on_data_fieldable_type_and_data_fieldable_id  (data_fieldable_type,data_fieldable_id)
#  index_data_fields_on_data_schema_id                             (data_schema_id)
#
class DataField < ApplicationRecord
  belongs_to :data_fieldable, polymorphic: true
  belongs_to :data_schema
end
