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

ActiveRecord::Schema[8.0].define(version: 0) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "animals", force: :cascade do |t|
    t.bigint "user_id"
    t.string "name", limit: 50
    t.bigint "breed_id"
    t.integer "age"
    t.integer "earring"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "breeds", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

    t.unique_constraint [ "name" ], name: "breeds_name_key"
  end

  create_table "device_animals", force: :cascade do |t|
    t.bigint "device_id"
    t.bigint "animal_id"
    t.datetime "start_date", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "end_date", precision: nil
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

    t.unique_constraint [ "device_id", "animal_id", "start_date" ], name: "unique_device_animal_period"
  end

  create_table "devices", force: :cascade do |t|
    t.string "serial_number", limit: 10, null: false
    t.string "api_key", limit: 36, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

    t.unique_constraint [ "serial_number" ], name: "devices_serial_number_key"
  end

  create_table "readings", force: :cascade do |t|
    t.bigint "device_id"
    t.bigint "animal_id"
    t.decimal "temperature", precision: 5, scale: 2
    t.decimal "sleep_time", precision: 5, scale: 2
    t.decimal "latitude", precision: 9, scale: 6
    t.decimal "longitude", precision: 9, scale: 6
    t.decimal "accel_x", precision: 7, scale: 4
    t.decimal "accel_y", precision: 7, scale: 2
    t.decimal "accel_z", precision: 7, scale: 2
    t.datetime "collected_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "email", limit: 120, null: false
    t.text "password_hash", null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

    t.unique_constraint [ "email" ], name: "users_email_key"
  end

  add_foreign_key "animals", "breeds", name: "animals_breed_id_fkey", on_delete: :nullify
  add_foreign_key "animals", "users", name: "animals_user_id_fkey", on_delete: :cascade
  add_foreign_key "device_animals", "animals", name: "device_animals_animal_id_fkey", on_delete: :cascade
  add_foreign_key "device_animals", "devices", name: "device_animals_device_id_fkey", on_delete: :cascade
  add_foreign_key "readings", "animals", name: "readings_animal_id_fkey", on_delete: :cascade
  add_foreign_key "readings", "devices", name: "readings_device_id_fkey", on_delete: :cascade
end
