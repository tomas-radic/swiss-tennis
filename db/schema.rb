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

ActiveRecord::Schema.define(version: 2021_01_31_124358) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "articles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", null: false
    t.text "content", null: false
    t.date "last_date_interesting"
    t.uuid "user_id", null: false
    t.uuid "season_id", null: false
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id"], name: "index_articles_on_season_id"
    t.index ["user_id"], name: "index_articles_on_user_id"
  end

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "enrollments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "season_id", null: false
    t.uuid "player_id", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "canceled_at"
    t.index ["player_id"], name: "index_enrollments_on_player_id"
    t.index ["season_id", "player_id"], name: "index_enrollments_on_season_id_and_player_id", unique: true
    t.index ["season_id"], name: "index_enrollments_on_season_id"
  end

  create_table "match_assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player_id"
    t.uuid "match_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_match_assignments_on_match_id"
    t.index ["player_id", "match_id"], name: "index_match_assignments_on_player_id_and_match_id", unique: true
    t.index ["player_id"], name: "index_match_assignments_on_player_id"
  end

  create_table "matches", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player1_id", null: false
    t.uuid "player2_id", null: false
    t.uuid "winner_id"
    t.uuid "round_id", null: false
    t.boolean "published", default: false, null: false
    t.boolean "from_toss", default: false, null: false
    t.datetime "finished_at"
    t.date "play_date"
    t.string "note", default: "", null: false
    t.integer "set1_player1_score"
    t.integer "set1_player2_score"
    t.integer "set2_player1_score"
    t.integer "set2_player2_score"
    t.integer "set3_player1_score"
    t.integer "set3_player2_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "retired_player_id"
    t.uuid "looser_id"
    t.integer "play_time"
    t.uuid "place_id"
    t.index ["place_id"], name: "index_matches_on_place_id"
    t.index ["player1_id"], name: "index_matches_on_player1_id"
    t.index ["player2_id"], name: "index_matches_on_player2_id"
    t.index ["round_id"], name: "index_matches_on_round_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount", null: false
    t.string "text_amount", null: false
    t.date "paid_on", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "places", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "position", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.boolean "active", default: true, null: false
    t.boolean "dummy", default: false, null: false
    t.boolean "consent_given", default: false, null: false
    t.index ["category_id"], name: "index_players_on_category_id"
  end

  create_table "rankings", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "player_id", null: false
    t.uuid "round_id", null: false
    t.integer "points", default: 0, null: false
    t.integer "games_difference", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sets_difference", default: 0, null: false
    t.boolean "relevant", default: false, null: false
    t.index ["player_id", "round_id"], name: "index_rankings_on_player_id_and_round_id", unique: true
    t.index ["player_id"], name: "index_rankings_on_player_id"
    t.index ["round_id"], name: "index_rankings_on_round_id"
  end

  create_table "rounds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "season_id"
    t.integer "position"
    t.string "label"
    t.date "period_begins"
    t.date "period_ends"
    t.boolean "closed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "specific_purpose", default: false, null: false
    t.index ["season_id"], name: "index_rounds_on_season_id"
  end

  create_table "seasons", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", default: 1, null: false
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "remember_token"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.uuid "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "articles", "seasons"
  add_foreign_key "articles", "users"
  add_foreign_key "enrollments", "players"
  add_foreign_key "enrollments", "seasons"
  add_foreign_key "match_assignments", "matches"
  add_foreign_key "match_assignments", "players"
  add_foreign_key "matches", "places"
  add_foreign_key "matches", "players", column: "player1_id"
  add_foreign_key "matches", "players", column: "player2_id"
  add_foreign_key "matches", "players", column: "winner_id"
  add_foreign_key "matches", "rounds"
  add_foreign_key "payments", "users"
  add_foreign_key "players", "categories"
  add_foreign_key "rankings", "players"
  add_foreign_key "rankings", "rounds"
  add_foreign_key "rounds", "seasons"
end
