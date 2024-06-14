class ChangeDatabaseTableRestraints < ActiveRecord::Migration[5.0]
  def change
    change_column :data_schemas, :fields, :jsonb, null: false
    change_column :data_fields, :data, :jsonb, null: false
    change_column :emails, :address, :string, null: false
    change_column :phones, :number, :string, null: false
    change_column :attendances, :date, :date, null: false
    change_column :attendances, :notice_date, :date
    change_column :attendances, :status, :string, null: false
    change_column :classrooms, :year, :integer, null: false
    change_column :enrollments, :result, :string, null: false
    change_column :evaluations, :content, :string, null: false
    change_column :people, :name, :string, null: false
    change_column :people, :gender, :string, null: false
    change_column :people, :birth_date, :date, null: false
    change_column :users, :admin, :boolean, null: false, default: false
    change_column :users, :password_digest, :string, null: false
    change_column :users, :username, :string, null: false
  end
end
