# == Schema Information
#
# Table name: addresses
#
#  id               :integer          not null, primary key
#  addressable_type :string
#  area             :string
#  city             :string
#  deleted_at       :datetime
#  district         :string
#  primary          :boolean          default(FALSE)
#  street_name      :string
#  street_number    :string
#  ward             :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  addressable_id   :integer
#
# Indexes
#
#  index_addresses_on_addressable_type_and_addressable_id  (addressable_type,addressable_id)
#
class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates_presence_of :primary, :addressable_type, :addressable_id

  FIELD_SETS = [
    {
      key: 'address',
      fields: [
        { field_name: :street_number, label: 'Số Nhà' },
        { field_name: :street_name, label: 'Đường' },
        { field_name: :ward, label: 'Phường/Xã' },
        { field_name: :district, label: 'Quận/Huyện' },
        { field_name: :area, label: 'Xóm Giáo' },
      ]
    }
  ]

  def full_address
    street_address = [street_number, street_name].reject(&:empty?).join(" ")
    [street_address, ward, district, city].reject(&:empty?).join(", ")
  end
end
