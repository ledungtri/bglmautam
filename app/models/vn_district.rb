# == Schema Information
#
# Table name: vn_districts
#
#  code          :integer          not null, primary key
#  codename      :string
#  division_type :string
#  name          :string           not null
#  province_code :integer          not null
#
# Indexes
#
#  index_vn_districts_on_province_code  (province_code)
#
class VnDistrict < ActiveRecord::Base
  self.primary_key = :code

  belongs_to :vn_province, foreign_key: :province_code
  has_many :vn_wards, foreign_key: :district_code
end
