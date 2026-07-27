class RemoveParentAndOccupationColumnsFromStudentsAndTeachers < ActiveRecord::Migration[7.2]
  def change
    remove_column :students, :father_christian_name, :string
    remove_column :students, :father_full_name, :string
    remove_column :students, :father_phone, :string
    remove_column :students, :mother_christian_name, :string
    remove_column :students, :mother_full_name, :string
    remove_column :students, :mother_phone, :string

    remove_column :teachers, :named_date, :string
    remove_column :teachers, :occupation, :string
  end
end
