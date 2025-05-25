# == Schema Information
#
# Table name: emails
#
#  id             :integer          not null, primary key
#  address        :string           not null
#  deleted_at     :datetime
#  emailable_type :string
#  primary        :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  emailable_id   :integer
#
# Indexes
#
#  index_emails_on_emailable_type_and_emailable_id  (emailable_type,emailable_id)
#
class Email < ApplicationRecord
  belongs_to :emailable, polymorphic: true
  # TODO: email = right format, allow nil

  validates_presence_of :address, :primary, :emailable_type, :emailable_id

  FIELD_SETS = [
    {
      key: 'email',
      fields: [
        { field_name: :address, label: 'Email' }
      ]
    }
  ]
end
