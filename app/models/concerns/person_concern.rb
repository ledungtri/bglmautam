module PersonConcern
  extend ActiveSupport::Concern

  included do
    include VnTextUtils
    validates_presence_of :full_name
    validates :phone, format: { with: /\A\d+\z/, message: 'only allows numbers' }, allow_blank: true
    validates_presence_of(:street_name, if: :street_number?) || :ward? || :district?
  end

  def name
    "#{christian_name} #{full_name}".squish
  end

  def address
    "#{street_number} #{street_name}, #{ward}, #{district}" if street_name?
  end

  def sort_param
    normalize(reverse(name))
  end
end