# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160226191550) do

  create_table "drug_thresholds", primary_key: "threshold_id", force: :cascade do |t|
    t.integer  "rxcui",      limit: 4
    t.integer  "threshold",  limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "general_inventories", primary_key: "gn_inventory_id", force: :cascade do |t|
    t.string   "rxaui",             limit: 255
    t.string   "gn_identifier",     limit: 255
    t.string   "lot_number",        limit: 255
    t.date     "expiration_date"
    t.integer  "received_quantity", limit: 4,   default: 0
    t.integer  "current_quantity",  limit: 4,   default: 0
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "news", primary_key: "news_id", force: :cascade do |t|
    t.string   "message",    limit: 255
    t.string   "type",       limit: 255
    t.boolean  "resolved",   limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "pap_inventories", primary_key: "pap_inventory_id", force: :cascade do |t|
    t.string   "rxaui",             limit: 255
    t.string   "lot_number",        limit: 255
    t.integer  "pap_identifier",    limit: 4
    t.integer  "patient_id",        limit: 4
    t.date     "expiry_date"
    t.integer  "received_quantity", limit: 4,   default: 0
    t.integer  "current_quantity",  limit: 4,   default: 0
    t.date     "reorder_date"
    t.date     "date_received"
    t.boolean  "voided",            limit: 1
    t.string   "void_reason",       limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "patients", primary_key: "patient_id", force: :cascade do |t|
    t.string   "epic_id",    limit: 255
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "gender",     limit: 255
    t.date     "birthdate"
    t.string   "address",    limit: 255
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "zip",        limit: 255
    t.string   "phone",      limit: 255
    t.boolean  "voided",     limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "prescriptions", primary_key: "rx_id", force: :cascade do |t|
    t.integer  "patient_id",  limit: 4
    t.string   "ndc",         limit: 255
    t.integer  "rxaui",       limit: 4
    t.date     "drug_name"
    t.integer  "quantity",    limit: 4
    t.integer  "provider_id", limit: 4
    t.boolean  "voided",      limit: 1
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "providers", primary_key: "provider_id", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

end
