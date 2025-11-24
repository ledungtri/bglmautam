# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_11_23_201005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", id: :serial, force: :cascade do |t|
    t.string "street_number"
    t.string "street_name"
    t.string "ward"
    t.string "district"
    t.string "city"
    t.string "area"
    t.boolean "primary", default: false
    t.string "addressable_type"
    t.integer "addressable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
  end

  create_table "attendances", id: :serial, force: :cascade do |t|
    t.date "date", null: false
    t.string "status", null: false
    t.date "notice_date"
    t.string "note"
    t.string "attendable_type"
    t.integer "attendable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.index ["attendable_type", "attendable_id"], name: "index_attendances_on_attendable_type_and_attendable_id"
  end

  create_table "classrooms", id: :serial, force: :cascade do |t|
    t.integer "year", null: false
    t.string "family"
    t.string "group"
    t.string "location"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "level"
    t.index ["deleted_at"], name: "index_classrooms_on_deleted_at"
  end

  create_table "data_schemas", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.string "title"
    t.string "entity", null: false
    t.jsonb "fields", null: false
    t.integer "weight", default: 0, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
  end

  create_table "emails", id: :serial, force: :cascade do |t|
    t.string "address", null: false
    t.boolean "primary", default: false
    t.string "emailable_type"
    t.integer "emailable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.index ["emailable_type", "emailable_id"], name: "index_emails_on_emailable_type_and_emailable_id"
  end

  create_table "enrollments", id: :serial, force: :cascade do |t|
    t.string "result", null: false
    t.integer "student_id"
    t.integer "classroom_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "person_id"
    t.index ["deleted_at"], name: "index_enrollments_on_deleted_at"
    t.index ["person_id"], name: "index_enrollments_on_person_id"
  end

  create_table "evaluations", id: :serial, force: :cascade do |t|
    t.string "content", null: false
    t.string "evaluable_type"
    t.integer "evaluable_id"
    t.datetime "deleted_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["evaluable_type", "evaluable_id"], name: "index_evaluations_on_evaluable_type_and_evaluable_id"
  end

  create_table "grades", id: :serial, force: :cascade do |t|
    t.string "name"
    t.float "value"
    t.integer "enrollment_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "weight", default: 1
    t.index ["enrollment_id"], name: "index_grades_on_enrollment_id"
  end

  create_table "people", id: :serial, force: :cascade do |t|
    t.string "christian_name"
    t.string "name", null: false
    t.string "gender", null: false
    t.date "birth_date", null: false
    t.string "birth_place"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.jsonb "data"
    t.string "nickname"
    t.string "avatar_url"
  end

  create_table "phones", id: :serial, force: :cascade do |t|
    t.string "number", null: false
    t.boolean "primary", default: false
    t.string "phoneable_type"
    t.integer "phoneable_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.index ["phoneable_type", "phoneable_id"], name: "index_phones_on_phoneable_type_and_phoneable_id"
  end

  create_table "resource_types", id: :serial, force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.string "weight", default: "0", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
  end

  create_table "students", id: :serial, force: :cascade do |t|
    t.string "christian_name"
    t.string "full_name"
    t.string "gender"
    t.string "phone"
    t.date "date_birth"
    t.string "place_birth"
    t.date "date_baptism"
    t.string "place_baptism"
    t.date "date_communion"
    t.string "place_communion"
    t.date "date_confirmation"
    t.string "place_confirmation"
    t.date "date_declaration"
    t.string "place_declaration"
    t.string "street_number"
    t.string "street_name"
    t.string "ward"
    t.string "district"
    t.string "area"
    t.string "father_christian_name"
    t.string "father_full_name"
    t.string "father_phone"
    t.string "mother_christian_name"
    t.string "mother_full_name"
    t.string "mother_phone"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "person_id"
    t.index ["deleted_at"], name: "index_students_on_deleted_at"
  end

  create_table "teachers", id: :serial, force: :cascade do |t|
    t.string "christian_name"
    t.string "full_name"
    t.string "named_date"
    t.date "date_birth"
    t.string "occupation"
    t.string "phone"
    t.string "email"
    t.string "street_number"
    t.string "street_name"
    t.string "ward"
    t.string "district"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.string "gender"
    t.integer "person_id"
    t.string "nickname"
    t.index ["deleted_at"], name: "index_teachers_on_deleted_at"
  end

  create_table "teaching_assignments", id: :serial, force: :cascade do |t|
    t.string "position"
    t.integer "teacher_id"
    t.integer "classroom_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.datetime "deleted_at", precision: nil
    t.integer "person_id"
    t.index ["deleted_at"], name: "index_teaching_assignments_on_deleted_at"
    t.index ["person_id"], name: "index_teaching_assignments_on_person_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "admin", default: false, null: false
    t.integer "teacher_id"
    t.datetime "deleted_at", precision: nil
    t.integer "person_id"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["person_id"], name: "index_users_on_person_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at", precision: nil
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "enrollments", "classrooms"
  add_foreign_key "enrollments", "people"
  add_foreign_key "teaching_assignments", "classrooms"
  add_foreign_key "teaching_assignments", "people"
  add_foreign_key "users", "people"
end
