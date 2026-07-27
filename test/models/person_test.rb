# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  area               :string
#  avatar_url         :string
#  birth_date         :date             not null
#  birth_place        :string
#  christian_name     :string
#  city               :string
#  data               :jsonb
#  date_baptism       :date
#  date_communion     :date
#  date_confirmation  :date
#  date_declaration   :date
#  deleted_at         :datetime
#  district           :string
#  email              :string
#  gender             :string           not null
#  name               :string           not null
#  nickname           :string
#  phone              :string
#  place_baptism      :string
#  place_communion    :string
#  place_confirmation :string
#  place_declaration  :string
#  province           :string
#  province_code      :integer
#  street_address     :string
#  street_name        :string
#  street_number      :string
#  subregion          :string
#  ward               :string
#  ward_code          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :bigint           not null
#
# Indexes
#
#  index_people_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
require "test_helper"

class PersonTest < ActiveSupport::TestCase
  setup do
    @organization = Organization.create!(name: "Test Org", slug: "test-org-#{SecureRandom.hex(4)}")
    ActsAsTenant.current_tenant = @organization
  end

  teardown do
    ActsAsTenant.current_tenant = nil
  end

  def new_person(attrs = {})
    Person.new({ name: "Test Person", gender: "Nam", birth_date: Date.new(2015, 1, 1) }.merge(attrs))
  end

  test "sacrament presence-pairing validation requires a date when a place is given" do
    person = new_person(place_baptism: "Nhà Thờ Mẫu Tâm")
    assert_not person.valid?
    assert_includes person.errors[:date_baptism], "can't be blank"
  end

  test "sacrament presence-pairing validation passes when both date and place are given" do
    person = new_person(place_baptism: "Nhà Thờ Mẫu Tâm", date_baptism: Date.new(2015, 2, 1))
    assert person.valid?
  end

  test "sacrament presence-pairing validation passes when neither date nor place is given" do
    person = new_person
    assert person.valid?
  end

  test "required custom data field blocks save when blank" do
    schema = DataSchema.create!(
      key: "test_required_#{SecureRandom.hex(4)}", entity: "Person", title: "Test", weight: 99,
      fields: [{ "field_name" => "test_field", "field_type" => "text_field", "label" => "Test Field", "required" => true }]
    )

    person = new_person
    assert_not person.valid?
    assert_includes person.errors[:base], "Test Field is required"
  end

  test "required custom data field allows save once present" do
    schema = DataSchema.create!(
      key: "test_required_#{SecureRandom.hex(4)}", entity: "Person", title: "Test", weight: 99,
      fields: [{ "field_name" => "test_field", "field_type" => "text_field", "label" => "Test Field", "required" => true }]
    )

    person = new_person
    person.data = { schema.key => { "test_field" => "filled in" } }
    assert person.valid?
  end

  test "non-required custom data field does not block save when blank" do
    DataSchema.create!(
      key: "test_optional_#{SecureRandom.hex(4)}", entity: "Person", title: "Test", weight: 99,
      fields: [{ "field_name" => "test_field", "field_type" => "text_field", "label" => "Test Field", "required" => false }]
    )

    person = new_person
    assert person.valid?
  end
end
