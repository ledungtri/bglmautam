# == Schema Information
#
# Table name: vn_wards
#
#  code           :integer          not null, primary key
#  name           :string           not null
#  division_type  :string
#  codename       :string
#  district_code  :integer          not null
#
# Indexes
#
#  index_vn_wards_on_district_code  (district_code)
#
class VnWard < ActiveRecord::Base
  self.primary_key = :code

  belongs_to :vn_district, foreign_key: :district_code
end
