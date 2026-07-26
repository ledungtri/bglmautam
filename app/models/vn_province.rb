# == Schema Information
#
# Table name: vn_provinces
#
#  code           :integer          not null, primary key
#  name           :string           not null
#  division_type  :string
#  codename       :string
#  phone_code     :integer
#
class VnProvince < ActiveRecord::Base
  self.primary_key = :code

  has_many :vn_districts, foreign_key: :province_code
end
