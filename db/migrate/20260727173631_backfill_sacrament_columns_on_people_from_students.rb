class BackfillSacramentColumnsOnPeopleFromStudents < ActiveRecord::Migration[7.2]
  # Person column => [Student column, legacy data['sacraments'] jsonb key]
  MAPPING = {
    date_baptism: [:date_baptism, 'baptism_date'],
    place_baptism: [:place_baptism, 'baptism_place'],
    date_communion: [:date_communion, 'communion_date'],
    place_communion: [:place_communion, 'communion_place'],
    date_confirmation: [:date_confirmation, 'confirmation_date'],
    place_confirmation: [:place_confirmation, 'confirmation_place'],
    date_declaration: [:date_declaration, 'declaration_date'],
    place_declaration: [:place_declaration, 'declaration_place']
  }.freeze

  def up
    Student.unscoped.with_deleted.find_each do |student|
      person = student.person
      next unless person

      sacraments = person.data.is_a?(Hash) ? (person.data['sacraments'] || {}) : {}
      updates = {}

      MAPPING.each do |person_column, (student_column, jsonb_key)|
        value = student[student_column].presence || sacraments[jsonb_key].presence
        updates[person_column] = value if value.present?
      end

      person.update_columns(updates) if updates.any?
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
