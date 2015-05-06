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

ActiveRecord::Schema.define(version: 20150505233803) do

  create_table "analytics", force: :cascade do |t|
    t.integer  "custid",          limit: 4
    t.integer  "elec_gas",        limit: 4
    t.string   "disconnect_doc",  limit: 255
    t.integer  "move_in_date",    limit: 4
    t.integer  "move_out_date",   limit: 4
    t.integer  "bill_year",       limit: 4
    t.integer  "bill_month",      limit: 4
    t.integer  "span_days",       limit: 4
    t.integer  "meter_read_date", limit: 4
    t.string   "meter_read_type", limit: 255
    t.integer  "consumption",     limit: 4
    t.string   "exception_code",  limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

end
