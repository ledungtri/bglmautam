module DataFieldable
  extend ActiveSupport::Concern

  included do
    validate :validate_required_data_fields
  end

  def data_field_by_key(key)
    self.data ||= {}
    self.data[key] || {}
  end

  def data_field_value(key, field)
    data_field_by_key(key)[field]
  end

  def update_data_field(key, params)
    self.data ||= {}
    self.data[key] ||= {}
    params.each { |field, value| self.data[key][field] = value }
    save
  end

  private

  def validate_required_data_fields
    DataSchema.where(entity: self.class.name).find_each do |schema|
      schema.fields.each do |field|
        next unless field['required']

        value = data_field_value(schema.key, field['field_name'])
        errors.add(:base, "#{field['label']} is required") if value.blank?
      end
    end
  end
end
