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
class AddressesController < SecondaryResourcesController

  private

  def model_klass
    Address
  end

  def permit_params
    [:street_number, :street_name, :ward, :district, :city, :area, :primary, :addressable_type, :addressable_id]
  end
end
