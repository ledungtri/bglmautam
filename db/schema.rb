# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20240614191521) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "street_number"
    t.string   "street_name"
    t.string   "ward"
    t.string   "district"
    t.string   "city"
    t.string   "area"
    t.boolean  "primary",          default: false
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.datetime "deleted_at"
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id", using: :btree
  end

  create_table "attendances", force: :cascade do |t|
    t.date     "date",            null: false
    t.string   "status",          null: false
    t.date     "notice_date"
    t.string   "note"
    t.string   "attendable_type"
    t.integer  "attendable_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.datetime "deleted_at"
    t.index ["attendable_type", "attendable_id"], name: "index_attendances_on_attendable_type_and_attendable_id", using: :btree
  end

  create_table "classrooms", force: :cascade do |t|
    t.integer  "year",       null: false
    t.string   "family"
    t.string   "group"
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer  "level"
    t.index ["deleted_at"], name: "index_classrooms_on_deleted_at", using: :btree
  end

  create_table "data_fields", force: :cascade do |t|
    t.jsonb    "data",                null: false
    t.string   "data_fieldable_type"
    t.integer  "data_fieldable_id"
    t.integer  "data_schema_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
    t.datetime "deleted_at"
    t.index ["data_fieldable_type", "data_fieldable_id"], name: "index_data_fields_on_data_fieldable_type_and_data_fieldable_id", using: :btree
    t.index ["data_schema_id"], name: "index_data_fields_on_data_schema_id", using: :btree
  end

  create_table "data_schemas", force: :cascade do |t|
    t.string   "key",                    null: false
    t.string   "title"
    t.string   "entity",                 null: false
    t.jsonb    "fields",                 null: false
    t.integer  "weight",     default: 0, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.datetime "deleted_at"
  end

  create_table "emails", force: :cascade do |t|
    t.string   "address",                        null: false
    t.boolean  "primary",        default: false
    t.string   "emailable_type"
    t.integer  "emailable_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "deleted_at"
    t.index ["emailable_type", "emailable_id"], name: "index_emails_on_emailable_type_and_emailable_id", using: :btree
  end

  create_table "enrollments", force: :cascade do |t|
    t.string   "result",       null: false
    t.integer  "student_id"
    t.integer  "classroom_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_enrollments_on_deleted_at", using: :btree
  end

  create_table "evaluations", force: :cascade do |t|
    t.string   "content",        null: false
    t.string   "evaluable_type"
    t.integer  "evaluable_id"
    t.datetime "deleted_at"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["evaluable_type", "evaluable_id"], name: "index_evaluations_on_evaluable_type_and_evaluable_id", using: :btree
  end

  create_table "guidances", force: :cascade do |t|
    t.string   "position"
    t.integer  "teacher_id"
    t.integer  "classroom_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_guidances_on_deleted_at", using: :btree
  end

  create_table "people", force: :cascade do |t|
    t.string   "christian_name"
    t.string   "name",           null: false
    t.string   "gender",         null: false
    t.date     "birth_date",     null: false
    t.string   "birth_place"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "deleted_at"
  end

  create_table "phones", force: :cascade do |t|
    t.string   "number",                         null: false
    t.boolean  "primary",        default: false
    t.string   "phoneable_type"
    t.integer  "phoneable_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "deleted_at"
    t.index ["phoneable_type", "phoneable_id"], name: "index_phones_on_phoneable_type_and_phoneable_id", using: :btree
  end

  create_table "students", force: :cascade do |t|
    t.string   "christian_name"
    t.string   "full_name"
    t.string   "gender"
    t.string   "phone"
    t.date     "date_birth"
    t.string   "place_birth"
    t.date     "date_baptism"
    t.string   "place_baptism"
    t.date     "date_communion"
    t.string   "place_communion"
    t.date     "date_confirmation"
    t.string   "place_confirmation"
    t.date     "date_declaration"
    t.string   "place_declaration"
    t.string   "street_number"
    t.string   "street_name"
    t.string   "ward"
    t.string   "district"
    t.string   "area"
    t.string   "father_christian_name"
    t.string   "father_full_name"
    t.string   "father_phone"
    t.string   "mother_christian_name"
    t.string   "mother_full_name"
    t.string   "mother_phone"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_students_on_deleted_at", using: :btree
  end

  create_table "teachers", force: :cascade do |t|
    t.string   "christian_name"
    t.string   "full_name"
    t.string   "named_date"
    t.date     "date_birth"
    t.string   "occupation"
    t.string   "phone"
    t.string   "email"
    t.string   "street_number"
    t.string   "street_name"
    t.string   "ward"
    t.string   "district"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.datetime "deleted_at"
    t.string   "gender"
    t.integer  "person_id"
    t.index ["deleted_at"], name: "index_teachers_on_deleted_at", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                        null: false
    t.string   "password_digest",                 null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "admin",           default: false, null: false
    t.integer  "teacher_id"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at", using: :btree
  end

end
