class UpdateResourceTypeKey < ActiveRecord::Migration[7.2]
  def up
    ResourceType.where(key: 'guidance_position').update_all(key: 'teaching_assignment_position')
  end

  def down
    ResourceType.where(key: 'teaching_assignment_position').update_all(key: 'guidance_position')
  end
end
