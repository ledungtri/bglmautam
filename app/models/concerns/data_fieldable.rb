module DataFieldable
  extend ActiveSupport::Concern

  def data_field_by_key(key)
    (self.data.detect { |df| df['key'] == key }) || { 'key' => key, 'values' => {} }
  end

  def data_field_value(key, field)
    data_field_by_key(key)['values'][field]
  end

  def update_data_field(key, params)
    self.data ||= []
    data_field = data_field_by_key(key)

    self.data.reject! { |df| df['key'] == key }
    params.each { |field, value| data_field['values'][field] = value }
    self.data << data_field
    save
  end
end
