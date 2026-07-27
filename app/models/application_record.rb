class ApplicationRecord < ActiveRecord::Base
  acts_as_paranoid

  self.abstract_class = true

  has_paper_trail meta: { organization_id: ->(record) { record.try(:organization_id) } }

  def attribute_names
    super - %w[id created_at updated_at deleted_at]
  end
end
