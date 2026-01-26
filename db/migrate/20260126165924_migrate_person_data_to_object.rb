class MigratePersonDataToObject < ActiveRecord::Migration[7.2]
  def up
    Person.find_each do |person|
      next if person.data.nil? || person.data.is_a?(Hash)

      new_data = {}
      person.data.each do |item|
        next unless item.is_a?(Hash) && item['key'].present?
        new_data[item['key']] = item['values'] || {}
      end
      person.update_column(:data, new_data)
    end
  end

  def down
    Person.find_each do |person|
      next if person.data.nil? || person.data.is_a?(Array)

      old_data = person.data.map do |key, values|
        { 'key' => key, 'values' => values }
      end
      person.update_column(:data, old_data)
    end
  end
end
