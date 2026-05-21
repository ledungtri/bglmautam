class AddOrganizationIdToAllTables < ActiveRecord::Migration[7.2]
  def change
    tables = %i[users people students teachers classrooms enrollments
                teaching_assignments attendances grades evaluations
                data_schemas resource_types]
    tables.each do |t|
      add_reference t, :organization, null: true, foreign_key: true, index: true
    end
  end
end
