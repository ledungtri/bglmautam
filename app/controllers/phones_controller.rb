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
class PhonesController < SecondaryResourcesController

  private

  def model_klass
    Phone
  end

  def permit_params
    [:number, :primary, :phoneable_type, :phoneable_id]
  end
end

