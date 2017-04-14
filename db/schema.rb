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

ActiveRecord::Schema.define(version: 20170414144703) do

  create_table "RXNATOMARCHIVE", id: false, force: :cascade do |t|
    t.string "RXAUI",             limit: 8,    null: false
    t.string "AUI",               limit: 10
    t.string "STR",               limit: 4000, null: false
    t.string "ARCHIVE_TIMESTAMP", limit: 280,  null: false
    t.string "CREATED_TIMESTAMP", limit: 280,  null: false
    t.string "UPDATED_TIMESTAMP", limit: 280,  null: false
    t.string "CODE",              limit: 50
    t.string "IS_BRAND",          limit: 1
    t.string "LAT",               limit: 3
    t.string "LAST_RELEASED",     limit: 30
    t.string "SAUI",              limit: 50
    t.string "VSAB",              limit: 40
    t.string "RXCUI",             limit: 8
    t.string "SAB",               limit: 20
    t.string "TTY",               limit: 20
    t.string "MERGED_TO_RXCUI",   limit: 8
  end

  create_table "RXNCONSO", id: false, force: :cascade do |t|
    t.string "RXCUI",    limit: 8,                    null: false
    t.string "LAT",      limit: 3,    default: "ENG", null: false
    t.string "TS",       limit: 1
    t.string "LUI",      limit: 8
    t.string "STT",      limit: 3
    t.string "SUI",      limit: 8
    t.string "ISPREF",   limit: 1
    t.string "RXAUI",    limit: 8,                    null: false
    t.string "SAUI",     limit: 50
    t.string "SCUI",     limit: 50
    t.string "SDUI",     limit: 50
    t.string "SAB",      limit: 20,                   null: false
    t.string "TTY",      limit: 20,                   null: false
    t.string "CODE",     limit: 50,                   null: false
    t.string "STR",      limit: 3000,                 null: false
    t.string "SRL",      limit: 10
    t.string "SUPPRESS", limit: 1
    t.string "CVF",      limit: 50
  end

  add_index "RXNCONSO", ["RXAUI"], name: "X_RXNCONSO_RXAUI", using: :btree

  create_table "RXNCUI", id: false, force: :cascade do |t|
    t.string "cui1",        limit: 8
    t.string "ver_start",   limit: 40
    t.string "ver_end",     limit: 40
    t.string "cardinality", limit: 8
    t.string "cui2",        limit: 8
  end

  create_table "RXNCUICHANGES", id: false, force: :cascade do |t|
    t.string "RXAUI",     limit: 8
    t.string "CODE",      limit: 50
    t.string "SAB",       limit: 20
    t.string "TTY",       limit: 20
    t.string "STR",       limit: 3000
    t.string "OLD_RXCUI", limit: 8,    null: false
    t.string "NEW_RXCUI", limit: 8,    null: false
  end

  create_table "RXNDOC", id: false, force: :cascade do |t|
    t.string "DOCKEY", limit: 50,   null: false
    t.string "VALUE",  limit: 1000
    t.string "TYPE",   limit: 50,   null: false
    t.string "EXPL",   limit: 1000
  end

  create_table "RXNREL", id: false, force: :cascade do |t|
    t.string "RXCUI1",   limit: 8
    t.string "RXAUI1",   limit: 8
    t.string "STYPE1",   limit: 50
    t.string "REL",      limit: 4
    t.string "RXCUI2",   limit: 8
    t.string "RXAUI2",   limit: 8
    t.string "STYPE2",   limit: 50
    t.string "RELA",     limit: 100
    t.string "RUI",      limit: 10
    t.string "SRUI",     limit: 50
    t.string "SAB",      limit: 20,   null: false
    t.string "SL",       limit: 1000
    t.string "DIR",      limit: 1
    t.string "RG",       limit: 10
    t.string "SUPPRESS", limit: 1
    t.string "CVF",      limit: 50
  end

  create_table "RXNSAB", id: false, force: :cascade do |t|
    t.string  "VCUI",   limit: 8
    t.string  "RCUI",   limit: 8
    t.string  "VSAB",   limit: 40
    t.string  "RSAB",   limit: 20,   null: false
    t.string  "SON",    limit: 3000
    t.string  "SF",     limit: 20
    t.string  "SVER",   limit: 20
    t.string  "VSTART", limit: 10
    t.string  "VEND",   limit: 10
    t.string  "IMETA",  limit: 10
    t.string  "RMETA",  limit: 10
    t.string  "SLC",    limit: 1000
    t.string  "SCC",    limit: 1000
    t.integer "SRL",    limit: 4
    t.integer "TFR",    limit: 4
    t.integer "CFR",    limit: 4
    t.string  "CXTY",   limit: 50
    t.string  "TTYL",   limit: 300
    t.string  "ATNL",   limit: 1000
    t.string  "LAT",    limit: 3
    t.string  "CENC",   limit: 20
    t.string  "CURVER", limit: 1
    t.string  "SABIN",  limit: 1
    t.string  "SSN",    limit: 3000
    t.string  "SCIT",   limit: 4000
  end

  create_table "RXNSAT", id: false, force: :cascade do |t|
    t.string "RXCUI",    limit: 8
    t.string "LUI",      limit: 8
    t.string "SUI",      limit: 8
    t.string "RXAUI",    limit: 9
    t.string "STYPE",    limit: 50
    t.string "CODE",     limit: 50
    t.string "ATUI",     limit: 11
    t.string "SATUI",    limit: 50
    t.string "ATN",      limit: 1000, null: false
    t.string "SAB",      limit: 20,   null: false
    t.string "ATV",      limit: 4000
    t.string "SUPPRESS", limit: 1
    t.string "CVF",      limit: 50
  end

  create_table "RXNSTY", id: false, force: :cascade do |t|
    t.string "RXCUI", limit: 8,   null: false
    t.string "TUI",   limit: 4
    t.string "STN",   limit: 100
    t.string "STY",   limit: 50
    t.string "ATUI",  limit: 11
    t.string "CVF",   limit: 50
  end

  create_table "dispensations", primary_key: "dispensation_id", force: :cascade do |t|
    t.integer  "rx_id",             limit: 4
    t.string   "inventory_id",      limit: 255
    t.integer  "patient_id",        limit: 4
    t.integer  "quantity",          limit: 4
    t.datetime "dispensation_date"
    t.boolean  "voided",            limit: 1,   default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "drug_threshold_sets", primary_key: "drug_set_id", force: :cascade do |t|
    t.integer  "threshold_id", limit: 4
    t.string   "rxaui",        limit: 255
    t.boolean  "voided",       limit: 1,   default: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  create_table "drug_thresholds", primary_key: "threshold_id", force: :cascade do |t|
    t.string   "rxaui",      limit: 255
    t.integer  "threshold",  limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "voided",     limit: 1,   default: false
    t.string   "rxcui",      limit: 255,                 null: false
  end

  create_table "general_inventories", primary_key: "gn_inventory_id", force: :cascade do |t|
    t.string   "rxaui",             limit: 255
    t.string   "gn_identifier",     limit: 255
    t.string   "lot_number",        limit: 255
    t.integer  "mfn_id",            limit: 4
    t.date     "expiration_date"
    t.date     "date_received"
    t.integer  "received_quantity", limit: 4,   default: 0
    t.integer  "current_quantity",  limit: 4,   default: 0
    t.boolean  "voided",            limit: 1,   default: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "void_reason",       limit: 255
    t.integer  "voided_by",         limit: 4
  end

  create_table "hl7_errors", force: :cascade do |t|
    t.integer  "patient_id",      limit: 4
    t.integer  "provider_id",     limit: 4
    t.datetime "date_prescribed"
    t.integer  "quantity",        limit: 4
    t.string   "directions",      limit: 255
    t.string   "drug_name",       limit: 255
    t.string   "code",            limit: 255
    t.boolean  "voided",          limit: 1,   default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "manufacturers", primary_key: "mfn_id", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "has_pmap",   limit: 1,   default: false
    t.boolean  "voided",     limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "ndc_code_matches", force: :cascade do |t|
    t.string   "missing_code", limit: 255
    t.string   "rxaui",        limit: 255
    t.string   "name",         limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "news", primary_key: "news_id", force: :cascade do |t|
    t.string   "message",       limit: 255
    t.string   "news_type",     limit: 255
    t.boolean  "resolved",      limit: 1,   default: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "refers_to",     limit: 255
    t.string   "resolution",    limit: 255
    t.date     "date_resolved"
  end

  create_table "patients", primary_key: "patient_id", force: :cascade do |t|
    t.string   "epic_id",    limit: 255
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "gender",     limit: 255
    t.date     "birthdate"
    t.string   "language",   limit: 255, default: "ENG"
    t.string   "address",    limit: 255
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "zip",        limit: 255
    t.string   "phone",      limit: 255
    t.boolean  "voided",     limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "pmap_inventories", primary_key: "pap_inventory_id", force: :cascade do |t|
    t.string   "rxaui",             limit: 255
    t.string   "lot_number",        limit: 255
    t.string   "pap_identifier",    limit: 255
    t.integer  "patient_id",        limit: 4
    t.date     "expiration_date"
    t.integer  "received_quantity", limit: 4,   default: 0
    t.integer  "current_quantity",  limit: 4,   default: 0
    t.date     "reorder_date"
    t.date     "date_received"
    t.boolean  "voided",            limit: 1,   default: false
    t.string   "void_reason",       limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.integer  "manufacturer",      limit: 4
  end

  create_table "prescriptions", primary_key: "rx_id", force: :cascade do |t|
    t.integer  "patient_id",       limit: 4
    t.string   "rxaui",            limit: 255
    t.datetime "date_prescribed"
    t.integer  "quantity",         limit: 4
    t.string   "directions",       limit: 255
    t.integer  "provider_id",      limit: 4
    t.boolean  "voided",           limit: 1,   default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "amount_dispensed", limit: 4,   default: 0
  end

  create_table "providers", primary_key: "provider_id", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_credentials", force: :cascade do |t|
    t.string   "password_hash", limit: 255
    t.string   "password_salt", limit: 255
    t.integer  "user_id",       limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.text     "first_name", limit: 65535
    t.text     "last_name",  limit: 65535
    t.text     "username",   limit: 65535
    t.text     "user_role",  limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.text     "username",   limit: 65535
    t.string   "user_role",  limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

end
