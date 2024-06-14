# == Schema Information
#
# Table name: phones
#
#  id             :integer          not null, primary key
#  deleted_at     :datetime
#  number         :string           not null
#  phoneable_type :string
#  primary        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  phoneable_id   :integer
#
# Indexes
#
#  index_phones_on_phoneable_type_and_phoneable_id  (phoneable_type,phoneable_id)
#
class Phone < ApplicationRecord
  belongs_to :phoneable, polymorphic: true

  validates :number, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
end
