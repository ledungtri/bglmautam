module DataFieldable
  extend ActiveSupport::Concern

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
end
