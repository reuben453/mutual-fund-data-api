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

ActiveRecord::Schema.define(version: 20170216175002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "keywords", force: :cascade do |t|
    t.text     "name"
    t.integer  "tag_id",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mutual_funds", force: :cascade do |t|
    t.string   "code",                  null: false
    t.string   "name",                  null: false
    t.string   "isin_growth"
    t.string   "isin_div_reinvestment"
    t.string   "mf_house_name",         null: false
    t.string   "scheme_category"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["code"], name: "index_mutual_funds_on_code", unique: true, using: :btree
    t.index ["isin_div_reinvestment"], name: "index_mutual_funds_on_isin_div_reinvestment", using: :btree
    t.index ["isin_growth"], name: "index_mutual_funds_on_isin_growth", using: :btree
    t.index ["name"], name: "index_mutual_funds_on_name", using: :btree
  end

  create_table "navs", force: :cascade do |t|
    t.decimal  "net_asset_value",  null: false
    t.decimal  "repurchase_price"
    t.decimal  "sale_price"
    t.date     "date",             null: false
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.integer  "mutual_fund_id",   null: false
    t.index ["mutual_fund_id", "date"], name: "index_navs_on_mutual_fund_id_and_date", unique: true, using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "share_prices", force: :cascade do |t|
    t.integer "stock_id", null: false
    t.decimal "open"
    t.decimal "high"
    t.decimal "low"
    t.decimal "close"
    t.date    "date",     null: false
    t.index ["date"], name: "index_share_prices_on_date", unique: true, using: :btree
  end

  create_table "stocks", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_stocks_on_name", using: :btree
  end

  create_table "tags", force: :cascade do |t|
    t.text     "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "navs", "mutual_funds"
  add_foreign_key "share_prices", "stocks"
end
