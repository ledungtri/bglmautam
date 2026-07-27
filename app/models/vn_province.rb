# == Schema Information
#
# Table name: vn_provinces
#
#  code          :integer          not null, primary key
#  codename      :string
#  division_type :string
#  name          :string           not null
#  phone_code    :integer
#
class VnProvince < ActiveRecord::Base
  self.primary_key = :code

  has_many :vn_districts, foreign_key: :province_code
end
