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

ActiveRecord::Schema[7.1].define(version: 2026_02_05_052706) do
  create_table "admin_users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
  end

  create_table "events", force: :cascade do |t|
    t.string "wedding_id", null: false
    t.string "name", null: false
    t.datetime "datetime"
    t.string "location"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wedding_id"], name: "index_events_on_wedding_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "wedding_id", null: false
    t.integer "household_id", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email"
    t.string "invite_code", null: false
    t.text "address"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["household_id"], name: "index_guests_on_household_id"
    t.index ["invite_code"], name: "index_guests_on_invite_code", unique: true
    t.index ["wedding_id"], name: "index_guests_on_wedding_id"
  end

  create_table "households", force: :cascade do |t|
    t.string "wedding_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["wedding_id"], name: "index_households_on_wedding_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.integer "guest_id", null: false
    t.datetime "sent_at"
    t.datetime "opened_at"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_id"], name: "index_invitations_on_guest_id"
  end

  create_table "rsvps", force: :cascade do |t|
    t.integer "guest_id", null: false
    t.string "status", default: "pending", null: false
    t.string "meal_choice"
    t.text "dietary_restrictions"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guest_id", "status"], name: "index_rsvps_on_guest_id_and_status"
    t.index ["guest_id"], name: "index_rsvps_on_guest_id"
  end

# Could not dump table "wedding_metadata" because of following StandardError
#   Unknown type 'uuid' for column 'id'

  add_foreign_key "guests", "households"
  add_foreign_key "invitations", "guests"
  add_foreign_key "rsvps", "guests"
end
