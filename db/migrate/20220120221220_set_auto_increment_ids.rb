class SetAutoIncrementIds < ActiveRecord::Migration[5.0]
  def change
    db_table_names = %w[enrollments cells instructions students teachers users]
    db_table_names.each { |table| execute "select setval(pg_get_serial_sequence('#{table}', 'id'), (select max(id) from #{table}));" }
  end
end
