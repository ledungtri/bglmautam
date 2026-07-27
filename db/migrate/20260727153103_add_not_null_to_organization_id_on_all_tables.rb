class AddNotNullToOrganizationIdOnAllTables < ActiveRecord::Migration[7.2]
  def change
    tables = %i[users people students teachers classrooms enrollments
                teaching_assignments attendances grades evaluations
                data_schemas resource_types]
    tables.each do |t|
      change_column_null t, :organization_id, false
    end
  end
end
