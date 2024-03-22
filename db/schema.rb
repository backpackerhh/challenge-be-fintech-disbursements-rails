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

ActiveRecord::Schema[7.1].define(version: 2024_03_21_204309) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "payments_merchant_disbursement_frequency_enum", ["DAILY", "WEEKLY"]

  create_table "payments_merchants", id: :uuid, default: nil, force: :cascade do |t|
    t.string "email", null: false
    t.string "reference", null: false
    t.enum "disbursement_frequency", null: false, enum_type: "payments_merchant_disbursement_frequency_enum"
    t.date "live_on", null: false
    t.decimal "minimum_monthly_fee", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_payments_merchants_on_reference", unique: true
  end

  create_table "payments_orders", id: :uuid, default: nil, force: :cascade do |t|
    t.string "reference", null: false
    t.integer "amount_cents", default: 0, null: false
    t.uuid "payments_merchant_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payments_merchant_id"], name: "index_payments_orders_on_payments_merchant_id"
    t.index ["reference"], name: "index_payments_orders_on_reference", unique: true
  end

  add_foreign_key "payments_orders", "payments_merchants"
end
