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

ActiveRecord::Schema.define(version: 2019_04_17_172453) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "matches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player1_id", null: false
    t.uuid "player2_id", null: false
    t.uuid "winner_id"
    t.uuid "round_id", null: false
    t.string "type", null: false
    t.boolean "published", default: false, null: false
    t.boolean "finished", default: false, null: false
    t.string "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player1_id"], name: "index_matches_on_player1_id"
    t.index ["player2_id"], name: "index_matches_on_player2_id"
    t.index ["round_id"], name: "index_matches_on_round_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "players", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone"
    t.string "email"
    t.integer "birth_year"
    t.uuid "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_players_on_category_id"
  end

  create_table "rounds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "season_id"
    t.integer "position"
    t.string "label"
    t.date "period_begins"
    t.date "period_ends"
    t.boolean "closed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_rounds_on_season_id"
  end

  create_table "seasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "matches", "players", column: "player1_id"
  add_foreign_key "matches", "players", column: "player2_id"
  add_foreign_key "matches", "players", column: "winner_id"
  add_foreign_key "matches", "rounds"
  add_foreign_key "players", "categories"
  add_foreign_key "rounds", "seasons"
end
