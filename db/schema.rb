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

ActiveRecord::Schema.define(version: 20220117212832) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attendances", force: :cascade do |t|
    t.string   "result"
    t.integer  "student_id"
    t.integer  "cell_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "year"
  end

  create_table "cells", force: :cascade do |t|
    t.integer  "year"
    t.string   "grade"
    t.string   "group"
    t.string   "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instructions", force: :cascade do |t|
    t.string   "position"
    t.integer  "teacher_id"
    t.integer  "cell_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "year"
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
  end

  create_table "users", force: :cascade do |t|
    t.string   "username"
    t.string   "password_digest"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.boolean  "isAdmin"
    t.integer  "teacher_id"
  end

end
