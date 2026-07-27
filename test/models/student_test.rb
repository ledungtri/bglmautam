# == Schema Information
#
# Table name: students
#
#  id                 :integer          not null, primary key
#  area               :string
#  christian_name     :string
#  date_baptism       :date
#  date_birth         :date
#  date_communion     :date
#  date_confirmation  :date
#  date_declaration   :date
#  deleted_at         :datetime
#  district           :string
#  full_name          :string
#  gender             :string
#  phone              :string
#  place_baptism      :string
#  place_birth        :string
#  place_communion    :string
#  place_confirmation :string
#  place_declaration  :string
#  street_name        :string
#  street_number      :string
#  ward               :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :bigint           not null
#  person_id          :integer
#
# Indexes
#
#  index_students_on_deleted_at       (deleted_at)
#  index_students_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "test_helper"

class StudentTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(name: "Test Org", slug: "test-org-#{SecureRandom.hex(4)}")
    ActsAsTenant.current_tenant = @organization
  end

  teardown do
    ActsAsTenant.current_tenant = nil
  end

  test "sync_person writes sacraments to native Person columns and parents_info to the custom field" do
    student = Student.create!(
      christian_name: "Maria",
      full_name: "Nguyễn Thị Test",
      gender: "Nữ",
      date_birth: Date.new(2014, 3, 1),
      date_baptism: Date.new(2014, 4, 1),
      place_baptism: "Nhà Thờ Mẫu Tâm",
      father_christian_name: "Giuse",
      father_full_name: "Nguyễn Văn Cha",
      father_phone: "0900000000",
      mother_christian_name: "Maria",
      mother_full_name: "Trần Thị Mẹ",
      mother_phone: "0911111111"
    )

    person = student.person
    assert_equal Date.new(2014, 4, 1), person.date_baptism
    assert_equal "Nhà Thờ Mẫu Tâm", person.place_baptism
    assert_equal "Giuse", person.data_field_value("parents_info", "father_christian_name")
    assert_equal "Nguyễn Văn Cha", person.data_field_value("parents_info", "father_name")
    assert_equal "0900000000", person.data_field_value("parents_info", "father_phone")
  end

  test "sync_person merges into existing custom field data instead of overwriting it" do
    student = Student.create!(
      full_name: "Test Student", gender: "Nam", date_birth: Date.new(2013, 5, 1),
      father_full_name: "Original Father"
    )
    person = student.person
    person.update_data_field("additional_info", { "occupation" => "Kỹ Sư" })

    student.update!(father_full_name: "Updated Father")

    person.reload
    assert_equal "Updated Father", person.data_field_value("parents_info", "father_name")
    assert_equal "Kỹ Sư", person.data_field_value("additional_info", "occupation")
  end

  test "reloading a student re-populates parents_info virtual attributes from the linked person" do
    student = Student.create!(
      full_name: "Test Student", gender: "Nam", date_birth: Date.new(2013, 5, 1),
      father_full_name: "Original Father Name"
    )

    reloaded = Student.find(student.id)
    assert_equal "Original Father Name", reloaded.father_full_name
  end
end
